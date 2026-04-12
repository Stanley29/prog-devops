# Jenkins CI/CD Pipeline on AWS EC2

A complete CI/CD pipeline implemented using Jenkins, GitHub, Maven, SSH, and Apache Tomcat, deployed across two AWS EC2 instances.

---

## 1. Assignment Requirements

1) Set up a personal Jenkins instance on an EC2 t2.small

2) Set up Apache HTTP + SSL Certificate + WildFly (or Apache Tomcat) on an existing EC2 t2.micro

3) Create a Jenkins job to build a GitHub repository

4) Deploy the built artifact to the application server using a Bash script (or alternative method)

---


## 2. Technologies Used

![AWS EC2](https://img.shields.io/badge/AWS-EC2-yellow)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-blue)
![GitHub SSH](https://img.shields.io/badge/GitHub-SSH%20Auth-black)
![Maven](https://img.shields.io/badge/Maven-Build%20Tool-orange)
![Java 17](https://img.shields.io/badge/Java-17-red)
![Apache HTTP Server](https://img.shields.io/badge/Apache-HTTP%20Server-red)
![Apache Tomcat 10](https://img.shields.io/badge/Tomcat-10-yellow)
![SSH / SCP](https://img.shields.io/badge/SSH-SCP-lightgrey)
![Bash](https://img.shields.io/badge/Bash-Scripting-green)
![Ubuntu Linux](https://img.shields.io/badge/Ubuntu-Linux%2022.04-orange)


---


## 3. Repository Structure


``` Code
project-05-jenkins-ci-cd/
│
├── README.md
│
├── images/
│   ├── 01_ec2_launch_instances.png
│   ├── 02_jenkins_instance_basic_settings.png
│   ├── 03_select_key_pair.png
│   ├── 04_security_group_jenkins.png
│   ├── 05_jenkins_instance_running.png
│   ├── 06_instance_public_ip.png
│   ├── 07_ssh_connected_jenkins_server.png
│   ├── 08_java_version_installed.png
│   ├── 08_jenkins_installed_and_running.png
│   ├── 10_initial_admin_password.png
│   ├── 11_jenkins_unlock_screen.png
│   ├── 12_jenkins_unlocked.png
│   ├── 14_plugins_installing.png
│   ├── 15_create_admin_user.png
│   ├── 17_jenkins_dashboard.png
│   ├── 18_jenkins_main_dashboard.png
│   ├── 19_new_item.png
│   ├── 20_pipeline_success.png
│   ├── 21_app_instance_basic_settings.png
│   ├── 22_app_security_group.png
│   ├── 23_app_instance_running.png
│   ├── 24_app_instance_public_ip.png
│   ├── 25_ssh_connected_app_server.png
│   ├── 26_apache_installed_status.png
│   ├── 27_apache_default_page.png
│   ├── 28_java_version_app_server.png
│   ├── 29_tomcat_installed_status.png
│   ├── 30_tomcat_default_page.png
│   ├── 31_tomcat_webapps_directory
│   ├── 32_jenkins_server_ssh_to_app_server_ping_successful.png
│   ├── 33_jenkins_new_freestyle_job.png
│   ├── 34_job_git_config.png
│   ├── 35_job_maven_build_step.png
│   ├── 36_job_archive_artifacts.png
│   ├── 37_pipeline_job_overview.png
│   ├── 38_pipeline_stages_view.png
│   ├── 39_console_output_start.png
│   ├── 40_console_output_success.png
│   ├── 41_jenkins_artifact_war.png
│   ├── 42_github_ssh_key_added.png
│   ├── 43_github_jenkinsfile.png
│   ├── 44_jenkins_credentials_github_ssh.png
│   ├── 45_deploy_script_on_app_server.png
│   ├── 46_jenkins_ssh_to_app_server.png
│   ├── 47_tomcat_webapps_listing.png
│   ├── 48_app_running_in_browser.png
│   ├── 49_jenkins_credentials_app_server_ssh.png
│   ├── 50_github_jenkinsfile_updated.png
│   ├── 51_deploy_script_full_view.png
│
└── scripts/
    ├── deploy.sh
    └── install_tomcat.sh (optional)
	
``` 
	
---


## 4. Architecture Overview

``` Code
GitHub → Jenkins (EC2) → SSH/SCP → App Server (EC2) → Tomcat → Browser
``` 

---


## 5. A — Infrastructure Setup (Jenkins Server + App Server)

### 5.1. Jenkins Server Setup

Launching EC2 instance

![01_ec2_launch_instances](images/01_ec2_launch_instances.png)

Instance configuration

![02_jenkins_instance_basic_settings](images/02_jenkins_instance_basic_settings.png)

Selecting SSH key pair

![03_select_key_pair](images/03_select_key_pair.png)

Security Group configuration

![04_security_group_jenkins](images/04_security_group_jenkins.png)

Instance running

![05_jenkins_instance_running](images/05_jenkins_instance_running.png)

Public IP

![06_instance_public_ip](images/06_instance_public_ip.png)

SSH connection

![07_ssh_connected_jenkins_server](images/07_ssh_connected_jenkins_server.png)

Command:

``` Code
ssh -i HrSolution_Key_Pair.pem ubuntu@13.48.48.97
``` 

Installing Java
(screenshot: 08_java_version_installed.png)

Commands:

``` Code
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version
``` 

Installing Jenkins

![08_java_version_installed](images/08_java_version_installed.png)


![08_jenkins_installed_and_running](images/08_jenkins_installed_and_running.png)

Commands:

``` Code
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
``` 

Initial admin password

![10_initial_admin_password](images/10_initial_admin_password.png)

Unlock Jenkins

![11_jenkins_unlock_screen](images/11_jenkins_unlock_screen.png)

Jenkins unlocked

![12_jenkins_unlocked](images/12_jenkins_unlocked.png)

Plugin installation

![14_plugins_installing](images/14_plugins_installing.png)

Creating admin user

![15_create_admin_user](images/15_create_admin_user.png)

Jenkins dashboard

![17_jenkins_dashboard](images/17_jenkins_dashboard.png)

Main dashboard

![18_jenkins_main_dashboard](images/18_jenkins_main_dashboard.png)

![19_new_item](images/19_new_item.png)

![20_pipeline_success](images/20_pipeline_success.png)

---


### 5.2. Application Server Setup

Launching EC2 instance

![21_app_instance_basic_settings](images/21_app_instance_basic_settings.png)

Security Group

![22_app_security_group](images/22_app_security_group.png)

Instance running

![23_app_instance_running](images/23_app_instance_running.png)

Public IP

![24_app_instance_public_ip](images/24_app_instance_public_ip.png)

SSH connection

![25_ssh_connected_app_server](images/25_ssh_connected_app_server.png)

Command:

``` Code
ssh -i HrSolution_Key_Pair.pem ubuntu@56.228.15.177
``` 

Installing Apache

![26_apache_installed_status](images/26_apache_installed_status.png)

Commands:

``` Code
sudo apt install -y apache2
sudo systemctl start apache2
``` 

Apache default page

![27_apache_default_page](images/27_apache_default_page.png)

Installing Java

![28_java_version_app_server](images/28_java_version_app_server.png)

Installing Tomcat

![29_tomcat_installed_status](images/29_tomcat_installed_status.png)

Command:

``` Code
sudo apt install -y tomcat10 tomcat10-admin
sudo systemctl start tomcat10
``` 

Tomcat default page

![30_tomcat_default_page](images/30_tomcat_default_page.png)

Java verification

![31_tomcat_webapps_directory](images/31_tomcat_webapps_directory.png)

Jenkins → App Server SSH test

![32_jenkins_server_ssh_to_app_server_ping_successful](images/32_jenkins_server_ssh_to_app_server_ping_successful.png)

## 6. B — Jenkins Freestyle Job Setup

Creating Freestyle job

![33_jenkins_new_freestyle_job](images/33_jenkins_new_freestyle_job.png)

GitHub repository configuration

![34_job_git_config](images/34_job_git_config.png)

Maven build step

![35_job_maven_build_step](images/35_job_maven_build_step.png)

Archiving artifacts

![36_job_archive_artifacts](images/36_job_archive_artifacts.png)

---


## 7. C — Pipeline-as-Code (Jenkinsfile)

Pipeline job overview

![37_pipeline_job_overview](images/37_pipeline_job_overview.png)

Stages view

![38_pipeline_stages_view](images/38_pipeline_stages_view.png)

Console output (start)

![39_console_output_start](images/39_console_output_start.png)

Console output (success)

![40_console_output_success](images/40_console_output_success.png)

Generated WAR artifact

![41_jenkins_artifact_war](images/41_jenkins_artifact_war.png)

---


## 8. D — GitHub Integration + Deployment

GitHub SSH key added

![42_github_ssh_key_added](images/42_github_ssh_key_added.png)

Jenkinsfile in repository

![43_github_jenkinsfile](images/43_github_jenkinsfile.png)

Jenkins credentials (github‑ssh)

![44_jenkins_credentials_github_ssh](images/44_jenkins_credentials_github_ssh.png)

deploy.sh on App Server

![45_deploy_script_on_app_server](images/45_deploy_script_on_app_server.png)

Jenkins SSH connection to App Server

![46_jenkins_ssh_to_app_server](images/46_jenkins_ssh_to_app_server.png)

Tomcat webapps directory

![47_tomcat_webapps_listing](images/47_tomcat_webapps_listing.png)

Application running in browser

![48_app_running_in_browser](images/48_app_running_in_browser.png)

Jenkins credentials (app-server-ssh)

![49_jenkins_credentials_app_server_ssh](images/49_jenkins_credentials_app_server_ssh.png)

Updated Jenkinsfile

![50_github_jenkinsfile_updated](images/50_github_jenkinsfile_updated.png)

Full deploy.sh

![51_deploy_script_full_view](images/51_deploy_script_full_view.png)

---

## 9. Scripts

deploy.sh

``` Code
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
``` 

Jenkinsfile

``` Code
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    credentialsId: 'github-ssh',
                    url: 'git@github.com:Stanley29/demo-webapp.git'
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Deploy to App Server') {
            steps {
                sshagent(['app-server-ssh']) {
                    sh '''
                        scp -o StrictHostKeyChecking=no target/demo-webapp.war ubuntu@56.228.15.177:/tmp/demo-webapp.war
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.15.177 sudo /opt/deploy.sh
                    '''
                }
            }
        }
    }
}
``` 

---

## 10. Final Result

- Jenkins successfully builds the Maven WAR

- Jenkins deploys the artifact to the App Server

- Tomcat automatically deploys the WAR

- The application is accessible in the browser

- The entire CI/CD pipeline works end‑to‑end without manual intervention

---

## 11. Conclusion

This project successfully demonstrates:

- A fully automated CI/CD pipeline

- Jenkins Pipeline-as-Code

- Secure SSH-based deployment

- Integration between GitHub → Jenkins → App Server

- A working Java web application deployed on Tomcat

