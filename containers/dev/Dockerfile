# Use the official code-server image as base
FROM codercom/code-server:latest

# Switch to root to install additional packages
USER root

# Install Zsh, Google Chrome, and dependencies
# Install Zsh, Google Chrome, Python, and dependencies
RUN apt-get update && apt-get install -y \
    zsh \
    curl \
    gnupg \
    git \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && apt-get clean

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
&& chsh -s $(which zsh) root
