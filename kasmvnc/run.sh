#!/usr/bin/env bash

#!/bin/bash

# Function to check if vncserver is already installed
check_installed() {
  if command -v vncserver &> /dev/null; then
    echo "vncserver is already installed."
    return 0 # Don't exit, just indicate it's installed
  else
    return 1 # Indicates not installed
  fi
}

# Function to install kasmvncserver for debian-based distros
install_deb() {
  local url=$1
  wget $url -O /tmp/kasmvncserver.deb
  sudo apt-get install --yes --no-install-recommends --no-install-suggests /tmp/kasmvncserver.deb
  sudo adduser $USER ssl-cert
  rm /tmp/kasmvncserver.deb
}

# Function to install kasmvncserver for Oracle 8
install_rpm_oracle8() {
  local url=$1
  wget $url -O /tmp/kasmvncserver.rpm
  sudo dnf config-manager --set-enabled ol8_codeready_builder
  sudo dnf install oracle-epel-release-el8 -y
  sudo dnf localinstall ./kasmvncserver_*.rpm -y
  sudo usermod -a -G kasmvnc-cert $USER
  rm /tmp/kasmvncserver.rpm
}

# Function to install kasmvncserver for CentOS 7
install_rpm_centos7() {
  local url=$1
  wget $url -O /tmp/kasmvncserver.rpm
  sudo yum install epel-release -y
  sudo yum install ./kasmvncserver_*.rpm -y
  sudo usermod -a -G kasmvnc-cert $USER
  rm /tmp/kasmvncserver.rpm
}

# Function to install kasmvncserver for rpm-based distros
install_rpm() {
  local url=$1
  wget $url -O /tmp/kasmvncserver.rpm
  sudo rpm -i /tmp/kasmvncserver.rpm
  rm /tmp/kasmvncserver.rpm
}

# Function to install kasmvncserver for Alpine Linux
install_alpine() {
  local url=$1
  wget $url -O /tmp/kasmvncserver.tgz
  tar -xzf /tmp/kasmvncserver.tgz -C /usr/local/bin/
  rm /tmp/kasmvncserver.tgz
}

# Detect system information
distro=$(grep "^ID=" /etc/os-release | awk -F= '{print $2}')
version=$(grep "^VERSION_ID=" /etc/os-release | awk -F= '{print $2}' | tr -d '"')
arch=$(uname -m)

echo "Detected Distribution: $distro"
echo "Detected Version: $version"
echo "Detected Architecture: $arch"

# Map arch to package arch
if [[ "$arch" == "x86_64" ]]; then
  if [[ "$distro" == "ubuntu" || "$distro" == "debian" || "$distro" == "kali" ]]; then
    arch="amd64"
  else
    arch="x86_64"
  fi
elif [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
  if [[ "$distro" == "ubuntu" || "$distro" == "debian" || "$distro" == "kali" ]]; then
    arch="arm64"
  else
    arch="aarch64"
  fi
else
  echo "Unsupported architecture: $arch"
  exit 1
fi

# Check if vncserver is installed, and install if not
if ! check_installed; then
  case $distro in
    ubuntu | debian | kali)
      case $version in
        "20.04")
          install_deb "https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_focal_${VERSION}_$${arch}.deb"
          ;;
        "22.04")
          install_deb "https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_jammy_${VERSION}_$${arch}.deb"
          ;;
        "24.04")
          install_deb "https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_noble_${VERSION}_$${arch}.deb"
          ;;
        *)
          echo "Unsupported Ubuntu/Debian/Kali version: $${version}"
          exit 1
          ;;
      esac
      ;;
    oracle)
      if [[ "$version" == "8" ]]; then
        install_rpm_oracle8 "https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_oracle_8_${VERSION}_$${arch}.rpm"
      else
        echo "Unsupported Oracle version: $${version}"
        exit 1
      fi
      ;;
    centos)
      if [[ "$version" == "7" ]]; then
        install_rpm_centos7 "https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_centos_core_${VERSION}_$${arch}.rpm"
      else
        install_rpm "https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_centos_core_${VERSION}_$${arch}.rpm"
      fi
      ;;
    alpine)
      if [[ "$version" == "3.17" || "$version" == "3.18" || "$version" == "3.19" || "$version" == "3.20" ]]; then
        install_alpine "https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvnc.alpine_$${version}_$${arch}.tgz"
      else
        echo "Unsupported Alpine version: $${version}"
        exit 1
      fi
      ;;
    fedora | opensuse)
      install_rpm "https://github.com/kasmtech/KasmVNC/releases/download/v${VERSION}/kasmvncserver_$${distro}_$${version}_${VERSION}_$${arch}.rpm"
      ;;
    *)
      echo "Unsupported distribution: $${distro}"
      exit 1
      ;;
  esac
else
  echo "vncserver already installed. Skipping installation."
fi

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
# and does not listen publicly
echo -e "password\npassword\n" | vncpasswd -wo -u $USER

# Start the server
printf "🚀 Starting KasmVNC server...\n"
sudo -u $USER bash -c "vncserver -select-de ${DESKTOP_ENVIRONMENT} -disableBasicAuth" > /tmp/kasmvncserver.log 2>&1 &
