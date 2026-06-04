#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl git

# Install k3s (Kubernetes)
curl -sfL https://get.k3s.io | sh -

# Configure kubectl for ubuntu user
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Clone your repo
cd /home/ubuntu
sudo -u ubuntu -H git clone https://github.com/Stanley29/CarServiceWorkshop.git

# Copy Helm chart
mkdir -p /home/ubuntu/carservice-chart
cp -r /home/ubuntu/CarServiceWorkshop/helm/carservice-chart/* /home/ubuntu/carservice-chart/
chown -R ubuntu:ubuntu /home/ubuntu/carservice-chart

# Deploy via Helm
helm install carservice /home/ubuntu/carservice-chart --namespace carservice --create-namespace
