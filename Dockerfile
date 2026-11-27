FROM ubuntu:24.04

# Set variable environment
ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1
ENV TERM=xterm-256color
ENV CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Trust the corporate TLS-inspection CA (exported from the macOS keychain into certs/).
# The proxy tampers with plain-HTTP apt downloads (Hash Sum mismatch), so apt is
# switched to HTTPS; the first update uses the CA file directly because the base
# image has no ca-certificates package yet.
COPY certs/corp-ca.crt /usr/local/share/ca-certificates/corp-ca.crt
RUN sed -i 's|http://|https://|g' /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get -o Acquire::https::CAInfo=/usr/local/share/ca-certificates/corp-ca.crt update && \
    apt-get -o Acquire::https::CAInfo=/usr/local/share/ca-certificates/corp-ca.crt install -y ca-certificates && \
    update-ca-certificates
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    PIP_CERT=/etc/ssl/certs/ca-certificates.crt \
    NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/corp-ca.crt

# Install base tools (make sure tar is included)
RUN apt-get update && apt-get install -y \
  curl \
  tar \
  git \
  fzf \
  ripgrep \
  fd-find \
  build-essential \
  gcc \
  lua5.4 \
  lua5.4-dev \
  luarocks \
  nodejs \
  npm \
  openjdk-17-jdk \
  python3 \
  python3-pip \
  pipx \
  passwd 

# Add to PATH
RUN pipx ensurepath

# sqlfluff: SQL / Jinja (Airflow) formatter + linter used by Neovim (lang/format.lua).
# Same version as the work projects' requirements-dev.txt so results match.
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install "sqlfluff==3.3.0"
# Default settings (postgres + jinja + fake Airflow variables); project configs override it
COPY docker/sqlfluff.cfg /root/.sqlfluff

RUN curl -fLo nvim-linux-arm64.tar.gz https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-arm64.tar.gz && \
# COPY ./nvim-linux-arm64.tar.gz ./nvim-linux-arm64.tar.gz
# RUN
    tar -xzf nvim-linux-arm64.tar.gz && \
    mv nvim-linux-arm64 /opt/nvim && \
    ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim && \
    rm nvim-linux-arm64.tar.gz

# Optional: Set root password
RUN echo "root:1234" | chpasswd

# Neovim config, baked into the image. Normal use: change ./src, then rebuild
# (docker compose build + up -d). For development, docker-compose.dev.yml
# bind-mounts ./src over this copy so edits apply on the next Neovim start.
COPY ./src /root/.config/nvim

# Install Claude Code CLI (used by coder/claudecode.nvim inside Neovim)
RUN npm install -g @anthropic-ai/claude-code

# Change shell to zsh
RUN chsh -s /bin/zsh