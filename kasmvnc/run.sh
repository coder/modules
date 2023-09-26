#!/usr/bin/env bash

# Update package list first
sudo apt-get update

# Pre-configure selections for tzdata
if [[ ! -f /etc/timezone ]]; then
    echo "tzdata tzdata/Areas select Etc" | sudo debconf-set-selections
    echo "tzdata tzdata/Zones/Etc select ${TIMEZONE}" | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
fi

# Pre-configure locales
echo "locales locales/default_environment_locale select ${LOCALE}" | sudo debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect ${LOCALE} UTF-8" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y locales

# Check if desktop environment is installed
if ! dpkg -s ${DESKTOP_ENVIRONMENT} &>/dev/null; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ${DESKTOP_ENVIRONMENT}
else
    echo "${DESKTOP_ENVIRONMENT} is already installed."
fi

# Check if vncserver is installed
if ! dpkg -s kasmvncserver &>/dev/null; then
    cd /tmp
    wget https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_focal_${VERSION}_amd64.deb
    sudo apt-get install -y ./kasmvncserver_focal_${VERSION}_amd64.deb
    printf "🥳 KasmVNC v${VERSION} has been successfully installed!\n\n"
else
    echo "KasmVNC is already installed."
fi

sudo addgroup $USER ssl-cert

# Coder port-forwarding from dashboard only supports HTTP
sudo bash -c 'cat > /etc/kasmvnc/kasmvnc.yaml <<EOF
network:
  protocol: http
  websocekt_port: ${PORT}
  ssl:
    require_ssl: false
  udp:
    public_ip: 127.0.0.1
EOF'

# This password is not used since we start the server without auth.
# The server is protected via the Coder session token / tunnel
# and does not listen publicly on the VM
echo -e "password\npassword\n" | vncpasswd -wo -u $USER

# Start the server :)
sudo su -u $USER bash -c 'vncserver -select-de "${DESKTOP_ENVIRONMENT}" -disableBasicAuth'
