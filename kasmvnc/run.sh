#!/usr/bin/env bash

# check if there is a WAIT_FOR_SCRIPT env variable and if so, wait for it to be available

# Wait for the startup script to complete
if [ -n "$WAIT_FOR_SCRIPT" ]; then
  # This assumes that the script will create a file called /tmp/.coder-${WAIT_FOR_SCRIPT}.done
  while [ ! -f /tmp/.coder-${WAIT_FOR_SCRIPT}.done ]; do
    sleep 1
  done
fi

# Check if desktop environment is installed
if ! dpkg -s $PACKAGES &> /dev/null; then
  sudo apt-get update
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y xfce4 xfce4-goodies libdatetime-perl --no-install-recommends --no-install-suggests
else
  echo "$PACKAGES is already installed."
fi

# Check if vncserver is installed
if ! dpkg -s kasmvncserver &> /dev/null; then
  DISTRO=$(lsb_release -c -s)
  ARCH=$(dpkg --print-architecture)
  wget -q https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_$${DISTRO}_${VERSION}_$${ARCH}.deb -O /tmp/kasmvncserver.deb
  sudo apt-get install -y /tmp/kasmvncserver.deb
  printf "🥳 KasmVNC v${VERSION} has been successfully installed!\n\n"
  sudo rm -f /tmp/kasmvncserver.deb
else
  echo "KasmVNC is already installed."
fi

sudo addgroup $USER ssl-cert

# Coder port-forwarding from dashboard only supports HTTP
sudo bash -c "cat > /etc/kasmvnc/kasmvnc.yaml <<EOF
network:
  protocol: http
  websocket_port: ${PORT}
  ssl:
    require_ssl: false
  udp:
    public_ip: 127.0.0.1
EOF"

# This password is not used since we start the server without auth.
# The server is protected via the Coder session token / tunnel
# and does not listen publicly on the VM
echo -e "password\npassword\n" | vncpasswd -wo -u $USER

# Start the server
printf "🚀 Starting KasmVNC server...\n"
sudo -u $USER bash -c 'vncserver -select-de xfce4 -disableBasicAuth' > /tmp/kassmvncserver.log 2>&1 &
