#!/bin/bash

# Script to install Apache on Debian/Ubuntu or RHEL/CentOS

set -e

if [ ! -f /etc/os-release ]; then
  echo "Cannot detect OS: /etc/os-release not found."
  exit 1
fi

. /etc/os-release

echo "Detected OS: $NAME"

if [[ "$ID_LIKE" == *"debian"* ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]]; then
  echo "Installing Apache (apache2) on Debian/Ubuntu..."
  sudo apt update
  sudo apt install -y apache2
  sudo systemctl enable apache2
  sudo systemctl start apache2
  sudo systemctl status apache2 --no-pager
elif [[ "$ID_LIKE" == *"rhel"* ]] || [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]]; then
  echo "Installing Apache (httpd) on RHEL/CentOS..."
  sudo yum install -y httpd
  sudo systemctl enable httpd
  sudo systemctl start httpd
  sudo systemctl status httpd --no-pager
else
  echo "Unsupported OS: $NAME"
  exit 1
fi

echo "Apache installation script finished."
