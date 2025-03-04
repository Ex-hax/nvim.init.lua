FROM node:latest

# Install LSP servers
RUN npm install -g \
    prettier \
    pyright \
    vscode-langservers-extracted \
    yaml-language-server \
    sql-language-server
