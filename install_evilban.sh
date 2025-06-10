#!/bin/bash

set -e

INSTALL_DIR="/usr/local/evilban"
CONF_SRC="evilban.conf"
CONF_DST="$INSTALL_DIR/evilban.conf"
LOGDIR="/var/log/evilban"
NEEDED_PKGS="grep sed ipset iptables ipcalc aggregate iprange python3"
CRON1="0 3 * * * root $INSTALL_DIR/evilban_cidr_aggregate.sh >> $LOGDIR/aggregate.log 2>&1"
CRON2="*/5 * * * * root $INSTALL_DIR/evilban_deflate_scan.sh >> $LOGDIR/deflate_scan.log 2>&1"
DDOS_DEF_DIR="/usr/local/ddos"

echo "[*] Installing required system packages..."
sudo apt-get update
sudo apt-get install -y $NEEDED_PKGS

echo "[*] Checking ddos-deflate..."
if [ ! -d "$DDOS_DEF_DIR" ]; then
    echo "[*] Cloning ddos-deflate..."
    sudo git clone https://github.com/jgmdev/ddos-deflate.git "$DDOS_DEF_DIR"
    sudo bash "$DDOS_DEF_DIR/install.sh"
else
    echo "[*] ddos-deflate is already installed."
fi

echo "[*] Creating directories..."
sudo mkdir -p "$INSTALL_DIR"
sudo mkdir -p "$LOGDIR"
sudo chmod 755 "$LOGDIR"

echo "[*] Copying files..."
sudo cp evilban_provider_by_range.sh evilban_deflate_scan.sh evilban_cidr_aggregate.sh evilban_providers.txt README.txt "$INSTALL_DIR/"
sudo cp "$CONF_SRC" "$CONF_DST"
sudo chmod +x "$INSTALL_DIR/"*.sh

echo "[*] Configuring cron..."
echo "$CRON1" | sudo tee /etc/cron.d/evilban_cidr > /dev/null
echo "$CRON2" | sudo tee /etc/cron.d/evilban_deflate > /dev/null
sudo chmod 644 /etc/cron.d/evilban_cidr /etc/cron.d/evilban_deflate

echo "[*] Installation complete."
echo "[*] Scripts: $INSTALL_DIR"
echo "[*] Logs:    $LOGDIR"
echo "[*] Config:  $CONF_DST"
echo "[*] Cron:"
echo "    $CRON1"
echo "    $CRON2"