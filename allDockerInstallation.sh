#!/bin/bash
set -euo pipefail

yum install docker -y
systemctl enable --now docker

echo "======================================"
echo " Installing latest Compose + Buildx"
echo "======================================"

# Detect CPU architecture
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        COMPOSE_ARCH="x86_64"
        BUILDX_ARCH="amd64"
        ;;
    aarch64|arm64)
        COMPOSE_ARCH="aarch64"
        BUILDX_ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Make sure curl is available
if ! command -v curl >/dev/null 2>&1; then
    echo "Installing curl..."
    sudo dnf install -y curl 2>/dev/null || sudo yum install -y curl
fi

echo
echo "Checking Docker..."
docker --version

# ---------------------------------------------------
# Docker Compose
# Installs standalone binary -> docker-compose
# ---------------------------------------------------

echo
echo "Finding latest Docker Compose version..."

COMPOSE_VERSION="$(
    curl -fsSL \
        -o /dev/null \
        -w '%{url_effective}' \
        https://github.com/docker/compose/releases/latest |
    sed 's#.*/tag/##'
)"

if [[ -z "$COMPOSE_VERSION" ]]; then
    echo "Failed to determine latest Docker Compose version."
    exit 1
fi

echo "Latest Compose: $COMPOSE_VERSION"
echo "Installing docker-compose..."

sudo curl -fL \
    "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${COMPOSE_ARCH}" \
    -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose


# ---------------------------------------------------
# Docker Buildx
# Installs as Docker CLI plugin -> docker buildx
# ---------------------------------------------------

echo
echo "Finding latest Docker Buildx version..."

BUILDX_VERSION="$(
    curl -fsSL \
        -o /dev/null \
        -w '%{url_effective}' \
        https://github.com/docker/buildx/releases/latest |
    sed 's#.*/tag/##'
)"

if [[ -z "$BUILDX_VERSION" ]]; then
    echo "Failed to determine latest Docker Buildx version."
    exit 1
fi

echo "Latest Buildx: $BUILDX_VERSION"
echo "Installing Docker Buildx..."

sudo mkdir -p /usr/local/lib/docker/cli-plugins

sudo curl -fL \
    "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-${BUILDX_ARCH}" \
    -o /usr/local/lib/docker/cli-plugins/docker-buildx

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx


# ---------------------------------------------------
# Verify
# ---------------------------------------------------

echo
echo "======================================"
echo " Installation completed"
echo "======================================"

echo
echo "Docker:"
docker --version

echo
echo "Docker Compose:"
docker-compose --version

echo
echo "Docker Buildx:"
docker buildx version