#!/bin/bash

# Script to install LAMP stack on Debian/Ubuntu or RHEL/CentOS

set -e

if [ ! -f /etc/os-release ]; then
  echo "Cannot detect OS: /etc/os-release not found."
  exit 1
fi

. /etc/os-release

echo "Detected OS: $NAME"

if [[ "$ID_LIKE" == *"debian"* ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]]; then
  echo "=== Installing LAMP on Debian/Ubuntu ==="
  sudo apt update

  echo "--- Installing Apache ---"
  sudo apt install -y apache2

  echo "--- Installing MariaDB ---"
  sudo apt install -y mariadb-server

  echo "--- Installing PHP ---"
  sudo apt install -y php libapache2-mod-php php-mysql

  echo "--- Enabling and starting services ---"
  sudo systemctl enable apache2
  sudo systemctl start apache2
  sudo systemctl enable mariadb
  sudo systemctl start mariadb

  WEB_ROOT="/var/www/html"

elif [[ "$ID_LIKE" == *"rhel"* ]] || [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]]; then
  echo "=== Installing LAMP on RHEL/CentOS ==="

  echo "--- Installing Apache ---"
  sudo yum install -y httpd

  echo "--- Installing MariaDB ---"
  sudo yum install -y mariadb-server

  echo "--- Installing PHP ---"
  sudo yum install -y php php-mysqlnd

  echo "--- Enabling and starting services ---"
  sudo systemctl enable httpd
  sudo systemctl start httpd
  sudo systemctl enable mariadb
  sudo systemctl start mariadb

  WEB_ROOT="/var/www/html"

else
  echo "Unsupported OS: $NAME"
  exit 1
fi

echo "--- Creating PHP info page ---"
sudo bash -c "echo '<?php phpinfo(); ?>' > ${WEB_ROOT}/info.php"

echo "LAMP installation completed."
echo "Open http://<your-server-ip>/info.php in browser to verify PHP."
