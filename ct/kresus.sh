#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/tug-benson/ProxmoxVE/refs/heads/tug_benson_ct/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Baptiste
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://wiki.bruno-tatu.com/informatique/install-kresus

# App Default Values
APP="Kresus"
var_tags="${var_tags:-finance;personal}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /home/kresus/kresus_app/node_modules/kresus ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Updating $APP LXC"
  sudo -u kresus bash << EOF
  cd /home/kresus/kresus_app
  npm uninstall kresus
  npm install kresus
EOF
  msg_ok "Updated $APP LXC"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9876${CL}"
