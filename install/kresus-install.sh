#!/usr/bin/env bash
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Baptiste
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://wiki.bruno-tatu.com/informatique/install-kresus

# Import Functions und Setup
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Installing Dependencies
msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  git \
  make \
  gcc \
  build-essential \
  python3-setuptools \
  python3-dev \
  python3-lxml \
  python3-html2text \
  python3-yaml \
  python3-pil \
  python3-pip \
  nodejs
msg_ok "Installed Dependencies"

# Create Kresus user
msg_info "Creating Kresus user"
adduser kresus --disabled-password --gecos Kresus
msg_ok "Kresus user created"

# Install Kresus and Woob
msg_info "Installing Kresus and Woob"
sudo -u kresus bash << EOF
cd /home/kresus
mkdir -p /home/kresus/kresus_app
npm install --prefix /home/kresus/kresus_app kresus
git clone https://gitlab.com/woob/woob -b stable-3.0 /home/kresus/kresus_app/woob
EOF
msg_ok "Kresus and Woob installed"

# Creating Service
msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/kresus.service
[Unit]
Description=Personal finance manager
After=network.target

[Service]
Type=simple
Restart=always
WorkingDirectory=/home/kresus
Environment=NODE_ENV=production
Environment=KRESUS_PYTHON_EXEC=python3
Environment=KRESUS_DB_TYPE=sqlite
Environment=KRESUS_DB_SQLITE_PATH=/home/kresus/kresus_app/kresus.sqlite
Environment=KRESUS_WEBOOB_DIR=/home/kresus/kresus_app/woob
ExecStart=/usr/bin/node /home/kresus/kresus_app/node_modules/kresus/bin/kresus.js
User=kresus

StandardOutput=journal
StandardError=inherit
SyslogIdentifier=kresus

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable -q --now kresus.service
msg_ok "Created Service"

motd_ssh
customize

# Cleanup
msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
