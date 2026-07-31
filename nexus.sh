#!/bin/bash

set -euo pipefail

echo "========================================"
echo " Installing Sonatype Nexus Repository"
echo "========================================"

# -------------------------------------------------
# 1. Must be run as root
# -------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script as root."
    echo "Example: sudo ./install-nexus.sh"
    exit 1
fi

# -------------------------------------------------
# 2. Required utilities
# -------------------------------------------------

dnf install -y tar gzip

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl command is not available."
    exit 1
fi

# -------------------------------------------------
# 3. Nexus configuration
# -------------------------------------------------

NEXUS_USER="nexus"
NEXUS_GROUP="nexus"

INSTALL_DIR="/opt"
NEXUS_HOME="/opt/nexus"
NEXUS_DATA="/opt/sonatype-work"

# IMPORTANT:
# Replace this with the CURRENT Linux x86-64 download URL
# from Sonatype's official download page.
NEXUS_URL="https://download.sonatype.com/nexus/3/nexus-3.94.1-06-linux-x86_64.tar.gz"


if [[ "$NEXUS_URL" == PASTE_* ]]; then
    echo
    echo "ERROR: Set NEXUS_URL before running the script."
    exit 1
fi


# -------------------------------------------------
# 4. Create Nexus user
# -------------------------------------------------

echo
echo "Creating Nexus service account..."

if ! id "$NEXUS_USER" >/dev/null 2>&1; then
    useradd \
        --system \
        --home-dir "$NEXUS_HOME" \
        --shell /sbin/nologin \
        "$NEXUS_USER"
fi


# -------------------------------------------------
# 5. Download Nexus
# -------------------------------------------------

echo
echo "Downloading Nexus..."

cd /tmp

rm -f nexus.tar.gz

curl -fL \
    "$NEXUS_URL" \
    -o nexus.tar.gz


# -------------------------------------------------
# 6. Extract Nexus
# -------------------------------------------------

echo
echo "Extracting Nexus..."

cd "$INSTALL_DIR"

rm -rf nexus-temp
mkdir nexus-temp

tar -xzf /tmp/nexus.tar.gz \
    -C nexus-temp

EXTRACTED_DIR=$(find nexus-temp \
    -mindepth 1 \
    -maxdepth 1 \
    -type d \
    | head -n 1)

if [[ -z "$EXTRACTED_DIR" ]]; then
    echo "ERROR: Could not locate extracted Nexus directory."
    exit 1
fi

rm -rf "$NEXUS_HOME"

mv "$EXTRACTED_DIR" "$NEXUS_HOME"

rm -rf nexus-temp


# -------------------------------------------------
# 7. Create Nexus data directory
# -------------------------------------------------

mkdir -p "$NEXUS_DATA"

chown -R "$NEXUS_USER:$NEXUS_GROUP" \
    "$NEXUS_HOME" \
    "$NEXUS_DATA"


# -------------------------------------------------
# 8. Configure Nexus service user
# -------------------------------------------------

NEXUS_RC="$NEXUS_HOME/bin/nexus.rc"

if [[ -f "$NEXUS_RC" ]]; then
    cat > "$NEXUS_RC" <<EOF
run_as_user="$NEXUS_USER"
EOF
fi


# -------------------------------------------------
# 9. Create systemd service
# -------------------------------------------------

echo
echo "Creating systemd service..."

cat > /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=Sonatype Nexus Repository
After=network.target

[Service]
Type=forking

User=$NEXUS_USER
Group=$NEXUS_GROUP

LimitNOFILE=65536

ExecStart=$NEXUS_HOME/bin/nexus start
ExecStop=$NEXUS_HOME/bin/nexus stop

Restart=on-abort

TimeoutSec=600

[Install]
WantedBy=multi-user.target
EOF


# -------------------------------------------------
# 10. Reload systemd
# -------------------------------------------------

systemctl daemon-reload


# -------------------------------------------------
# 11. Enable Nexus at boot
# -------------------------------------------------

systemctl enable nexus


# -------------------------------------------------
# 12. Start Nexus
# -------------------------------------------------

echo
echo "Starting Nexus..."

systemctl start nexus


# -------------------------------------------------
# 13. Show status
# -------------------------------------------------

sleep 5

echo
echo "========================================"
echo " Nexus installation completed"
echo "========================================"

systemctl status nexus --no-pager || true

echo
echo "Nexus normally listens on:"
echo
echo "    http://<EC2-PUBLIC-IP>:8081"
echo
echo "Check logs with:"
echo
echo "    journalctl -u nexus -f"
echo
echo "Initial admin password, once generated:"
echo
echo "    $NEXUS_DATA/nexus3/admin.password"
echo