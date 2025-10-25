FROM ubuntu:24.04

# Set variable environment
ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1

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

# RUN curl -fLo nvim-linux-arm64.tar.gz https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-arm64.tar.gz && \
COPY ./nvim-linux-arm64.tar.gz ./nvim-linux-arm64.tar.gz
RUN tar -xzf nvim-linux-arm64.tar.gz && \
    mv nvim-linux-arm64 /opt/nvim && \
    ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim && \
    rm nvim-linux-arm64.tar.gz

# Optional: Set root password
RUN echo "root:1234" | chpasswd

# Stores in plaintext (~/.git-credentials)
RUN git config --global credential.helper 'store --file=/root/.git-credentials'

# Create folder for nvim lazy
RUN mkdir -p /root/.config

# Copy credentials and clone the repo
COPY .git-credentials /root/.git-credentials
RUN git clone https://github.com/Ex-hax/nvim.init.lua.git /root/.config/ntmp && \
    cd /root/.config/ntmp && \
    git fetch origin && \
    # git branch arm64 && \
    # git checkout arm64 && \
    # git pull origin arm64 && \
    git checkout hotfix/arm64 && \
    git pull origin hotfix/arm64 && \
    cd && \
    mv /root/.config/ntmp/src /root/.config/nvim && \
    rm /root/.git-credentials && \
    rm -rf /root/.config/ntmp

# Change shell to zsh
RUN chsh -s /bin/zsh