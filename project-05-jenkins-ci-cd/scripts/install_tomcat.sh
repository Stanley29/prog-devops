#!/bin/bash

sudo apt update
sudo apt install -y tomcat10 tomcat10-admin

sudo systemctl enable tomcat10
sudo systemctl start tomcat10

echo "Tomcat installed and running."
