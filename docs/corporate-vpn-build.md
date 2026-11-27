# Building the image on the company VPN

On the company network/VPN, a TLS-inspection proxy re-signs HTTPS traffic with the
company's own root CA. Docker and the tools inside the image don't trust that CA, so
the build fails with errors like:

- `x509: certificate signed by unknown authority` (pulling `ubuntu:24.04` from Docker Hub)
- `Hash Sum mismatch` from `apt-get` (the proxy tampers with plain-HTTP apt downloads)
- `SSL certificate problem` / `UNABLE_TO_GET_ISSUER_CERT` from curl, npm or pip

The fix: export the company CA from the macOS keychain into `certs/`, let the build
trust it, and let BuildKit trust it for pulling base images.

> `certs/` is in `.gitignore`. Never commit the certificate files.

---

## 1. Export the company CA certificate (once)

Find the CA's name. The proxy's certificate chain shows it as the issuer:

```bash
openssl s_client -connect registry-1.docker.io:443 -showcerts </dev/null 2>/dev/null \
  | grep -E '^ *i:' | tail -1
# e.g.  i:/DC=local/DC=<company>/CN=<Company> Enterprise CA
#       → the CA name is the part after CN=
```

Export it from the keychains into `certs/corp-ca.crt`:

```bash
cd ~/personal/nvim.init.lua
mkdir -p certs
CA_NAME="<Company> Enterprise CA"     # the CN from the step above

for kc in /Library/Keychains/System.keychain \
          /System/Library/Keychains/SystemRootCertificates.keychain \
          ~/Library/Keychains/login.keychain-db; do
  security find-certificate -a -c "$CA_NAME" -p "$kc" 2>/dev/null
done > certs/corp-ca.crt
```

Check it:

```bash
grep -c 'BEGIN CERT' certs/corp-ca.crt          # should be 1 or more
openssl x509 -in certs/corp-ca.crt -noout -subject -issuer -enddate
```

If the file is empty, open **Keychain Access**, search for the CA, right-click it, choose
**Export…** in `.pem` format, and save it as `certs/corp-ca.crt`.

## 2. What the Dockerfile does with it (already in place)

```dockerfile
COPY certs/corp-ca.crt /usr/local/share/ca-certificates/corp-ca.crt
RUN sed -i 's|http://|https://|g' /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get -o Acquire::https::CAInfo=/usr/local/share/ca-certificates/corp-ca.crt update && \
    apt-get -o Acquire::https::CAInfo=/usr/local/share/ca-certificates/corp-ca.crt install -y ca-certificates && \
    update-ca-certificates
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    PIP_CERT=/etc/ssl/certs/ca-certificates.crt \
    NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/corp-ca.crt
```

- apt is switched to **HTTPS**, because the proxy breaks plain-HTTP apt downloads.
- The first `apt-get` passes the CA file directly, because the base image doesn't have
  `ca-certificates` yet.
- The `ENV` lines make curl, git, Python/pip and Node/npm (Claude Code) trust the CA,
  both during the build and inside the running container.

## 3. Create a BuildKit builder that trusts the CA (once)

Pulling `ubuntu:24.04` happens **before** the Dockerfile runs, so BuildKit itself has to
trust the CA:

```bash
cd ~/personal/nvim.init.lua
cat > certs/buildkitd.toml <<EOF
[registry."docker.io"]
  ca = ["$PWD/certs/corp-ca.crt"]
EOF

docker buildx create --name corp-builder --driver docker-container \
  --buildkitd-config certs/buildkitd.toml --bootstrap
```

Check that it can reach Docker Hub:

```bash
docker buildx imagetools inspect --builder corp-builder ubuntu:24.04 | head -3
```

## 4. Build the image

```bash
cd ~/personal/nvim.init.lua
docker compose build --builder corp-builder
```

Fallback if the builder doesn't work: the legacy builder uses Docker Desktop's own
trust settings.

```bash
DOCKER_BUILDKIT=0 docker compose build
```

## 5. Use the new image without losing data

```bash
docker compose up -d        # recreates the container from the new image
```

This **keeps** the named volumes:

| Volume | Holds |
|---|---|
| `nvim_data` | plugins (lazy), **Mason** LSP servers, sessions |
| `claude_config` | Claude Code login and conversations |

Don't run `docker compose down -v` or `docker volume rm`, which delete them.

**Config changes:** the Neovim config (`./src`) is baked into the image, so after
changing it, rebuild (step 4) and run `docker compose up -d`.

For development, start the container with the dev override. It bind-mounts `./src`,
so an edit applies the next time Neovim starts, with no rebuild:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

When you're done, rebuild and run a plain `docker compose up -d` to go back to the
image's config.

---

## Troubleshooting

| Error | Cause / fix |
|---|---|
| `x509: certificate signed by unknown authority` while pulling the base image | Build with `--builder corp-builder` (step 3), or use `DOCKER_BUILDKIT=0`. |
| `x509` from a builder like `multiarch-builder` | That builder doesn't have the CA. Use `corp-builder`, or recreate the other builder with `--buildkitd-config certs/buildkitd.toml`. |
| `Hash Sum mismatch` from apt | apt is still on HTTP. Make sure the `sed ... https://` line runs before the first `apt-get`. |
| `COPY failed: certs/corp-ca.crt not found` | Step 1 wasn't done on this machine (`certs/` isn't in git). |
| Errors after the company replaces its CA | Export it again (step 1). The builder reads the file each build, but recreate it if it fails: `docker buildx rm corp-builder`, then step 3. |
| Builds fine **off** the VPN? | Nothing to change. Trusting an extra CA doesn't break normal networks. |
