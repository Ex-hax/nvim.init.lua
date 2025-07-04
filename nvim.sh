#!/bin/bash

# ==============================================
# nvim-docker launcher for iTerm2
# Path: ~/personal/nvim/nvim.sh
# ==============================================

CONTAINER_NAME="nvim"
NVIM_COMMAND="nvim"
FALLBACK_SHELL="$SHELL"  # Fallback to user's default shell

# ANSI color codes for error messages
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }

# Check Docker status
if ! docker info >/dev/null 2>&1; then
    error "Docker daemon is not running"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        warning "Trying to start Docker Desktop..."
        open -a Docker
        sleep 10  # Wait for Docker to initialize
        if ! docker info >/dev/null 2>&1; then
            error "Failed to start Docker automatically"
            warning "Falling back to regular shell"
            exec $FALLBACK_SHELL
        fi
    else
        exec $FALLBACK_SHELL
    fi
fi

# Check container existence
if ! docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    error "Container '$CONTAINER_NAME' does not exist"
    warning "Available containers:"
    docker ps -a --format "{{.Names}}" | sed 's/^/  - /' >&2
    exec $FALLBACK_SHELL
fi

# Check container status
CONTAINER_STATUS=$(docker container inspect -f '{{.State.Status}}' "$CONTAINER_NAME")
if [[ "$CONTAINER_STATUS" != "running" ]]; then
    warning "Container '$CONTAINER_NAME' is $CONTAINER_STATUS, attempting to start..."
    if ! docker start "$CONTAINER_NAME" >/dev/null; then
        error "Failed to start container '$CONTAINER_NAME'"
        exec $FALLBACK_SHELL
    fi
    sleep 1  # Brief pause after starting container
fi

# Launch Neovim with proper environment
exec docker exec -it \
    -e TERM="$TERM" \
    -e COLORTERM="$COLORTERM" \
    -e NVIM="$NVIM_COMMAND" \
    "$CONTAINER_NAME" \
    "$NVIM_COMMAND" "$@"
