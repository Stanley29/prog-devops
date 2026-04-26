#!/bin/bash

set -e

### 1. Update system
apt update -y
apt install -y apt-transport-https ca-certificates curl unzip awscli openjdk-17-jdk apache2

### 2. Install Jenkins (correct key)
### Install Jenkins (correct key)
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update -y
apt install -y jenkins



systemctl enable jenkins
systemctl start jenkins

### 3. Enable Apache
systemctl enable apache2
systemctl start apache2

### 4. Create SSL certificate (non-interactive)
mkdir -p /etc/apache2/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/apache2/ssl/apache.key \
  -out /etc/apache2/ssl/apache.crt \
  -subj "/C=DE/ST=SL/L=Saarbruecken/O=DevOps/OU=IT/CN=jenkins.local"

### 5. Enable Apache modules
a2enmod ssl
a2enmod proxy
a2enmod proxy_http

### 6. Configure Apache reverse proxy for Jenkins
cat <<EOF >/etc/apache2/sites-available/jenkins.conf
<VirtualHost *:443>
    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
</VirtualHost>
EOF

a2ensite jenkins.conf
systemctl reload apache2

### 7. Restore JENKINS_HOME from S3 (if exists)
aws s3 sync s3://jenkins-backup-sergii/ /var/lib/jenkins/ || true
chown -R jenkins:jenkins /var/lib/jenkins

### 8. Setup cron backup every 10 minutes
cat <<EOF >/etc/cron.d/jenkins-backup
*/10 * * * * root aws s3 sync /var/lib/jenkins/ s3://jenkins-backup-sergii/
EOF
