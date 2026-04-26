#!/bin/bash
set -e

apt update -y
apt install -y openjdk-17-jdk

useradd -m -s /bin/bash jenkins || true
