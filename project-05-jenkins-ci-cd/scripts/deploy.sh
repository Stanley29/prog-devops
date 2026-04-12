#!/bin/bash

echo "Stopping Tomcat..."
sudo systemctl stop tomcat10

echo "Removing old deployment..."
sudo rm -rf /var/lib/tomcat10/webapps/demo-webapp
sudo rm -f /var/lib/tomcat10/webapps/demo-webapp.war

echo "Copying new WAR..."
sudo cp /tmp/demo-webapp.war /var/lib/tomcat10/webapps/

echo "Starting Tomcat..."
sudo systemctl start tomcat10

echo "Deployment completed."
