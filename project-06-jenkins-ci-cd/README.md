# Project 06 вЂ“ Jenkins CI/CD with SSH Slaves and WildFly on AWS

This project provisions a Jenkins-based CI/CD pipeline on AWS EC2 using Terraform.

## Components

- Jenkins Master (EC2)
- Two Jenkins SSH Slaves (EC2)
- WildFly Deployment Server (EC2)
- Terraform IaC
- SSH-based deployment pipeline

## Structure

`
project-06-jenkins-ci-cd/
в”‚в”Ђв”Ђ README.md
в”‚в”Ђв”Ђ Jenkinsfile
в”‚в”Ђв”Ђ jenkins-install.sh
в”‚в”Ђв”Ђ slave-setup.sh
в”‚в”Ђв”Ђ wildfly-install.sh
в”‚в”Ђв”Ђ images/
в””в”Ђв”Ђ terraform/
в”‚в”Ђв”Ђ main.tf
в”‚в”Ђв”Ђ variables.tf
в”‚в”Ђв”Ђ outputs.tf
в”‚в”Ђв”Ђ ec2-master.tf
в”‚в”Ђв”Ђ ec2-slave1.tf
в”‚в”Ђв”Ђ ec2-slave2.tf
в”‚в”Ђв”Ђ ec2-wildfly.tf
в”‚в”Ђв”Ђ security-groups.tf
в””в”Ђв”Ђ keypair.tf
`


## Usage

cd terraform
terraform init
terraform apply


Terraform will output:

- Jenkins Master IP
- Slave #1 IP
- Slave #2 IP
- WildFly Server IP

✅ Completed Steps
01. Preparing PowerShell and launching the project generation script
During this stage, the following actions were performed:

Navigated to the working directory

Set the ExecutionPolicy for the current session

Launched the init_project_06.ps1 script

📸 Screenshot:  
01_powershell_script_start.png  
Shows the confirmation of changing the ExecutionPolicy.

02. Running the script and generating the project structure
The script was successfully executed using:

Code
.\init_project_06.ps1
The script generated the initial project structure:

Code
project-06-jenkins-ci-cd/
  README.md
  Jenkinsfile
  *.sh
  terraform/
📸 Screenshot:  
02_run_script.png  
Shows the successful script execution and the message Project created successfully.

03. Navigating into the Terraform directory
Moved into the Terraform configuration folder:

Code
cd project-06-jenkins-ci-cd/terraform
📸 Screenshot:  
03_cd_into_terraform_folder.png  
Shows the correct working directory before running Terraform commands.

04. Initializing Terraform
Executed:

Code
terraform init
Terraform successfully:

downloaded the AWS provider

created .terraform.lock.hcl

prepared the working directory

📸 Screenshot:  
06_terraform_init_success.png  
Shows the message Terraform has been successfully initialized!

05. Validating the infrastructure plan
Executed:

Code
terraform plan
Terraform successfully generated a plan:

7 resources to be created

no errors

AMI found in eu-north-1

VPC and key pair detected correctly

📸 Screenshot:  
07_terraform_plan.png  
Shows the full execution plan with all resources marked as + create.

06. Deploying the Infrastructure with Terraform
06.1 Running terraform apply
To deploy the full AWS infrastructure (Jenkins Master, two Jenkins Slaves, and WildFly server), the following command was executed:

Code
terraform apply
Terraform displayed the execution plan and requested confirmation.
The deployment was approved by entering:

Code
yes
📸 Screenshot:  
08_terraform_apply_start.png  
Shows the moment when the apply process was started and confirmed.

06.2 Infrastructure Deployment Completed
After several minutes, Terraform successfully created all required resources:

4 EC2 instances

3 security groups

All user‑data scripts applied

Public IPs generated for each server

Terraform output included:

jenkins_master_ip

slave1_ip

slave2_ip

wildfly_ip

📸 Screenshot:  
09_terraform_apply_finished.png  
Shows the final output of Terraform with all created resources and public IP addresses.

ssh -i HrSolution_Key_Pair.pem ubuntu@13.51.168.127

✅ 08. Preparing the Jenkins Master Node
After connecting to the Jenkins Master EC2 instance, the following system preparation steps were performed:

Updated package lists

Ensured the system was ready for Jenkins installation

Verified network connectivity and system state

✅ 09. Removing the broken Jenkins repository
The default Jenkins APT repository was removed because it is currently broken and produces GPG signature errors on Ubuntu 22.04.

Actions performed:

Removed old jenkins.list

Cleaned outdated keys

Prepared the system for a clean installation path

✅ 10. Adding the new official Jenkins key
A new, updated Jenkins GPG key (2023 format) was downloaded and added:

Downloaded key

Converted to .gpg

Placed into /usr/share/keyrings/jenkins-keyring.gpg

This step ensured compatibility with modern APT security requirements.

✅ 11. Adding the Jenkins repository (attempt)
A new repository entry was created:

Code
deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/
APT was updated, but the repository still failed due to global Jenkins GPG issues.

✅ 12. Adding Jenkins key to trusted.gpg.d (workaround)
To bypass the broken repository signature, the key was added to:

Code
/etc/apt/trusted.gpg.d/jenkins.gpg
APT was updated again — but the repository remained broken.

⚠️ Conclusion:
The Jenkins APT repository is globally broken in 2025–2026.  
Therefore, we switched to a guaranteed working installation method.

✅ 13. Downloading Jenkins .deb package
The official stable Jenkins package was downloaded directly:

Code
jenkins_2.452.1_all.deb
This bypassed the broken repository entirely.

✅ 14. Installing Jenkins via dpkg
Executed:

Code
sudo dpkg -i jenkins_2.452.1_all.deb
This installed Jenkins but reported missing dependencies — expected behavior for dpkg.

✅ 15. Fixing dependencies
Executed:

Code
sudo apt install -f -y
This:

Installed net-tools

Installed all required Java dependencies

Automatically completed Jenkins configuration

✅ 16. Starting Jenkins service
Executed:

Code
sudo systemctl start jenkins
Jenkins service successfully launched.

✅ 17. Verifying Jenkins status
Executed:

Code
systemctl status jenkins
The output confirmed:

active (running)

Java process running

Jenkins fully initialized

No errors

📸 Screenshot:  
10_jenkins_installed_master.png 


🎉 Final Result
Jenkins is fully installed, configured, and running on the EC2 instance.

📸 Screenshot:  
11_jenkins_web_page.png 


18. Retrieving the Jenkins Initial Admin Password

After the Jenkins service started successfully, the next step was to retrieve the initial administrator password required to unlock the Jenkins web interface.
This password is automatically generated during the first startup and stored in the Jenkins secrets directory.

The following command was executed to display the password:

🖼 Recommended screenshot name
18_initial_admin_password.png

19. Unlocking the Jenkins Web Interface

After retrieving the initial administrator password from the Jenkins master node, the next step was to unlock the Jenkins web interface.
The Jenkins dashboard becomes accessible through the browser once the service is running.
To proceed with the initial setup, the following URL was opened in a web browser:

http://51.20.74.204:8080

On the “Unlock Jenkins” page, the previously retrieved password was entered:

Code
5b9d8332160e4c53b885350025dfb35a
This successfully unlocked the Jenkins setup wizard and allowed the configuration process to continue.

🖼 Recommended screenshot name
19_unlock_jenkins_page.png

20. Installing Suggested Jenkins Plugins

After unlocking Jenkins, the setup wizard prompted for plugin installation.
To ensure a stable and compatible environment, the “Install suggested plugins” option was selected.
This action triggered Jenkins to automatically download and install the recommended set of plugins, including:

Git

SSH Build Agents

Pipeline

Credentials

Workspace Cleanup

Matrix Authorization

and other essential components

The installation process may take several minutes as Jenkins fetches plugins from the update center and configures them.

🖼 Recommended screenshot name
20_install_suggested_plugins.png

21. Creating the First Jenkins Administrator Account

After skipping the plugin installation due to update center issues, Jenkins proceeded to the next step of the setup wizard: creating the initial administrator account.
This account will be used to log into Jenkins and manage all CI/CD operations, including configuring nodes, pipelines, credentials, and plugins.

The following fields were filled in:

Username

Password

Full Name

Email Address

Once the form was completed, the “Save and Continue” button was clicked, finalizing the creation of the admin user.

🖼 Recommended screenshot name
21_create_admin_user.png

22. Configuring the Jenkins Instance URL

After creating the administrator account, Jenkins prompted for the instance URL configuration.
This URL defines how Jenkins generates absolute links for build pages, artifacts, notifications, and webhook callbacks.
The default value proposed by Jenkins was:

Code
http://51.20.74.204:8080/
Since this is the correct public address of the Jenkins master EC2 instance, the default value was accepted without changes.
The configuration was saved by clicking Save and Finish.

🖼 Recommended screenshot name
22_instance_configuration.png

23. Jenkins Setup Completed

After configuring the instance URL, Jenkins finalized the setup process and displayed the confirmation screen indicating that the installation was successful.
The message “Jenkins is ready!” confirms that the initial configuration wizard has been completed and the Jenkins master node is fully operational.
From this point, the Jenkins dashboard becomes accessible, allowing further configuration such as installing plugins, adding SSH build agents, and setting up CI/CD pipelines.

The setup was completed by clicking Start using Jenkins, which redirected to the main Jenkins dashboard.

🖼 Recommended screenshot name
23_jenkins_is_ready.png

24. Fixing Plugin Installation After Completing the Setup Wizard

During the initial setup, the plugin installation failed due to outdated Jenkins core and incompatible plugin dependencies.
After upgrading Jenkins to the latest LTS version (2.555.1) and cleaning the plugin directory, the plugin manager became fully functional.

To verify that the update center works correctly, I navigated to:
Manage Jenkins → Plugins → Updates  
and clicked Check now.

Jenkins successfully refreshed the update metadata and reported:
“No updates available”, confirming that the system is healthy and ready for plugin installation.

After that, I proceeded to install the required plugins (Git, Credentials, Pipeline, SSH Build Agents, etc.), all of which installed successfully without dependency issues.

25. Configure Jenkins SSH Slave #1
(English report for your documentation)

25.1 — Connecting to Jenkins Slave #1
In this step, I connected to the first Jenkins slave EC2 instance using the assigned AWS key pair.
The connection was established successfully via SSH using the following command:

Code
ssh -i HrSolution_Key_Pair.pem ubuntu@16.16.26.174
After logging in, the system displayed the standard Ubuntu welcome banner, confirming that the instance is reachable and ready for further configuration.

This completes the initial access phase for Slave #1 and prepares the node for Java installation and SSH agent setup in the next steps.

🖼 Recommended screenshot name:
25_1_slave1_ssh_connection.png

25.2 — Installing Java on Jenkins Slave #1
(English report for your documentation)

In this step, Java 21 was successfully installed on the first Jenkins slave node.
The following commands were executed on the instance:

Code
sudo apt update
sudo apt install -y openjdk-21-jdk
java -version
The output confirmed that OpenJDK 21 is installed and operational:

Code
openjdk version "21.0.10" 2026-01-20
OpenJDK Runtime Environment (build 21.0.10+7-Ubuntu-122.04)
OpenJDK 64-Bit Server VM (build 21.0.10+7-Ubuntu-122.04, mixed mode, sharing)
This completes the Java installation required for the Jenkins SSH agent to run on Slave #1.

🖼 Recommended screenshot name:
25_2_slave1_java_installed.png

25.3 — Creating Jenkins User on Slave #1
(English report for your documentation)

In this step, a dedicated system user named jenkins was created on the first Jenkins slave node.
This user will be used by the Jenkins master to establish an SSH connection and run build tasks on the agent.

The following actions were performed:

A new user and group jenkins were created using:

Code
sudo adduser jenkins
The password and user information were successfully configured.

The user was added to the sudo group to allow elevated operations when required:

Code
sudo usermod -aG sudo jenkins
The .ssh directory was created and secured:

Code
sudo mkdir -p /home/jenkins/.ssh
sudo chown -R jenkins:jenkins /home/jenkins/.ssh
sudo chmod 700 /home/jenkins/.ssh
This prepares the environment for adding the authorized SSH key in the next step.

🖼 Recommended screenshot name:
25_3_slave1_jenkins_user_created.png

STEP 25.4.1 — Generate SSH Key on Jenkins Master (Completed)
(English report for your documentation)

In this step, an SSH key pair was successfully generated for the Jenkins master node.
This key will be used by Jenkins to authenticate and connect to the slave nodes via SSH.

The following command was executed:

Code
sudo -u jenkins ssh-keygen -t rsa -b 4096 -C "jenkins@master"
The key pair was created in the default Jenkins SSH directory:

/var/lib/jenkins/.ssh/id_rsa

/var/lib/jenkins/.ssh/id_rsa.pub

The output confirmed successful generation of both the private and public keys.

This completes the SSH key creation step and prepares the master node for secure communication with Slave #1.

🖼 Recommended screenshot name:
25_4_1_master_ssh_key_generated.png

STEP 25.4 — Adding Jenkins Master SSH Key to Slave #1
(English report for your documentation)

In this step, the public SSH key generated on the Jenkins master node was successfully added to the authorized_keys file of the jenkins user on Slave #1.
This allows the Jenkins master to authenticate and connect to the slave securely without a password.

The following actions were performed on Slave #1:

The master’s public key was appended to the authorized keys file:

Code
echo "<public_key>" | sudo tee -a /home/jenkins/.ssh/authorized_keys
Ownership and permissions were set correctly:

Code
sudo chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
sudo chmod 600 /home/jenkins/.ssh/authorized_keys
Verification confirmed that the key is present in the file:

Code
sudo cat /home/jenkins/.ssh/authorized_keys
This completes the SSH trust setup between the Jenkins master and Slave #1.

🖼 Recommended screenshot name:
25_4_slave1_authorized_key_added.png

STEP 25.5 — Testing SSH Connection from Jenkins Master to Slave #1
(English report for your documentation)

In this step, the SSH connection from the Jenkins master node to Slave #1 was successfully tested using the Jenkins system user.
The following command was executed on the master:

Code
sudo -u jenkins ssh -o StrictHostKeyChecking=no jenkins@16.16.26.174
The connection was established without requiring a password, confirming that the SSH key-based authentication is configured correctly.

Once logged in, the following verification commands were executed:

Code
whoami
hostname
The output confirmed:

The active user is jenkins

The remote host is ip-172-31-24-100 (Slave #1)

This validates that the Jenkins master can securely access Slave #1 and is ready to use it as an SSH build agent.

🖼 Recommended screenshot name:
25_5_master_to_slave1_ssh_test.png

26. Configuring Jenkins SSH Slave #2
In this step, the second Jenkins SSH agent was configured and connected to the Jenkins master.
The configuration process is identical to Slave #1.

26.1 — Connect to Slave #2
Code
ssh -i HrSolution_Key_Pair.pem ubuntu@13.60.237.208
26.2 — Create Jenkins user
Code
sudo adduser jenkins --disabled-password --gecos ""
sudo usermod -aG sudo jenkins
26.3 — Prepare SSH directory
Code
sudo mkdir -p /home/jenkins/.ssh
sudo chown -R jenkins:jenkins /home/jenkins/.ssh
sudo chmod 700 /home/jenkins/.ssh
26.4 — Add Jenkins master public key
Code
echo "<public_key>" | sudo tee /home/jenkins/.ssh/authorized_keys
sudo chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
sudo chmod 600 /home/jenkins/.ssh/authorized_keys
26.5 — Install Java
Code
sudo apt update
sudo apt install -y openjdk-21-jdk
26.6 — Add Slave #2 in Jenkins
Node name: slave2

Host: 13.60.237.208

Remote root: /home/jenkins

Launch method: SSH

Credentials: slave1-ssh

Host key verification: Non-verifying

After saving the configuration, the agent successfully connected and appeared as online in the Jenkins Nodes list.

🖼 Recommended screenshot name:
26_4_slave2_authorized_key_added.png


26.5 — Install Java on Jenkins Slave #2
(English description for your documentation)  
In this step, Java 21 is installed on Jenkins Slave #2.
Java is required for running the Jenkins remoting agent, which allows the master to communicate with the node.

Recommended screenshot name:  
26_5_slave2_java_installed.png

26.6 — Add Slave #2 in Jenkins UI
(English description for your documentation)  
In this step, the second Jenkins SSH agent is added to the Jenkins master through the Jenkins UI.
The node is configured to connect via SSH using the same credentials as Slave #1.
Once saved, Jenkins will attempt to authenticate, copy the remoting agent, and bring the node online.

Recommended screenshot name:  
26_6_slave2_node_configuration.png

26.7 — Final Result: Slave #2 Online
(English description for your documentation)  
In this step, the Jenkins master successfully connected to Slave #2 using SSH.
The remoting agent was launched, the communication channel was established, and the node appeared as online in the Jenkins Nodes dashboard.

This confirms that both Jenkins SSH agents are fully operational and ready to execute distributed CI/CD workloads.

Recommended screenshot name:  
26_7_slave2_online.png

27. Preparing the WildFly Deployment Server (Step 1 — SSH Connection)
(English description for your documentation)

27.1 — Connect to the WildFly Deployment Server
(English description for your documentation)

In this step, I connected to the WildFly EC2 instance using the AWS key pair assigned at launch.
This verifies that the server is reachable and ready for installing the WildFly application server, which will serve as the deployment target for the CI/CD pipeline.

Server details:

Public IP: 13.48.29.172

Private IP: 172.31.25.174

Hostname: ip-172-31-25-174.eu-north-1.compute.internal

Instance type: t3.micro

AMI: Ubuntu 22.04 (Jammy)

Key pair: HrSolution_Key_Pair

Recommended screenshot name:  
27_1_wildfly_ssh_connection.png

27.2 — Install Java on the WildFly Server
(English description for your documentation)

In this step, Java 21 is installed on the WildFly EC2 instance.
WildFly requires a Java runtime environment to operate, and Java 21 ensures compatibility with modern Jakarta EE deployments.

Recommended screenshot name:  
27_2_wildfly_java_installed.png

27.3 — Download and Install WildFly Application Server
(English description for your documentation)

In this step, the WildFly application server is downloaded, extracted, and installed on the EC2 instance.
WildFly will serve as the deployment target for the Jenkins CI/CD pipeline.
The installation includes creating a dedicated directory, unpacking the server, and preparing it for service configuration.

Recommended screenshot name:  
27_3_wildfly_download_and_install.png

27.4 — Create WildFly System User and Set Permissions
(English description for your documentation)

In this step, a dedicated system user named wildfly is created to run the WildFly application server.
This ensures proper isolation, security, and correct ownership of the WildFly installation directory.
The WildFly folder is then assigned to this user so the service can run without elevated privileges.

Recommended screenshot name:  
27_4_wildfly_user_and_permissions.png

27.5 — Create the WildFly systemd Service
(English description for your documentation)

In this step, a systemd service is created to manage the WildFly application server as a background service.
This allows WildFly to start automatically at boot, run under the dedicated wildfly user, and be controlled using standard systemctl commands.
The service file defines the startup command, environment variables, and working directory for the server.

Recommended screenshot name:  
27_5_wildfly_systemd_service_created.png

27.6 — Enable WildFly to Start Automatically on Boot
(English description for your documentation)

In this step, the WildFly systemd service is configured to start automatically whenever the server boots.
This ensures that the application server remains available after reboots, maintenance operations, or unexpected restarts.
The commands below enable the service and verify that it is correctly registered in systemd.

Commands executed:

Code
sudo systemctl enable wildfly
systemctl is-enabled wildfly
Recommended screenshot name:  
27_6_wildfly_enable_autostart.png

27.7 — Open Port 8080 for WildFly (Security Group Update)
(English description for your documentation)

In this step, port 8080 is opened in the EC2 Security Group to allow external access to the WildFly web interface.
WildFly listens on port 8080 by default, and without this rule the application server would not be reachable from the internet.
This step ensures that Jenkins, developers, and browsers can access the deployed application.

Commands executed:  
(Port opening is done in AWS Console, not via Linux commands)

Navigate to EC2 → Security Groups

Select the Security Group attached to the WildFly instance

Add an inbound rule:

Type: Custom TCP

Port: 8080

Source: 0.0.0.0/0 (or your IP for restricted access)

Recommended screenshot name:  
27_7_wildfly_open_port_8080.png

27.8 — Verify WildFly Web Interface
(English description for your documentation, including commands)

In this step, the WildFly server is verified by accessing its default web interface through the public IP address.
This confirms that the application server is running correctly, the firewall rules are configured, and the service is reachable from the internet.

Commands executed on the server:

Code
sudo systemctl status wildfly
Browser URL to test:

Code
http://13.48.29.172:8080
If WildFly is running correctly, you should see the WildFly Welcome Page.

Recommended screenshot name:  
27_8_wildfly_web_interface.png

27.9 — Configure WildFly for Application Deployments (Management User)
(English description for your documentation, including commands)

In this step, a WildFly management user is created.
This user is required for deploying applications remotely from Jenkins using the WildFly CLI or the management API.
The management user will have administrative privileges and will be used by Jenkins during automated deployments.

Commands executed:

Code
cd /opt/wildfly/bin
sudo ./add-user.sh
During the interactive prompt, the following options must be selected:

Type: Management User

Username: jenkins

Password: (your choice, strong password)

Groups: (leave empty)

Is this correct? yes

This creates the file:

Code
/opt/wildfly/standalone/configuration/mgmt-users.properties
Recommended screenshot name:  
27_9_wildfly_management_user_created.png

27.10 (оновлено) — Enable Remote Management Interface via CLI
(English description for your documentation, including commands)

In this step, the WildFly management interface is configured to listen on all network interfaces using the official WildFly CLI tool.
This method is version‑safe and avoids manual XML editing.
It ensures that Jenkins can connect to the management API on port 9990 for remote deployments.

Commands executed:

Code
cd /opt/wildfly/bin
sudo ./jboss-cli.sh --connect
Inside the CLI:

Code
/interface=management:write-attribute(name=inet-address,value=0.0.0.0)
:reload
This updates the management interface binding and reloads the server configuration.

Recommended screenshot name:  
27_10_wildfly_management_interface_cli.png


27.11 — Install WildFly CLI on Jenkins Master
(English description for your documentation, including commands)

In this step, the WildFly CLI tool is installed on the Jenkins master server.
The CLI is required for Jenkins to communicate with the WildFly management interface on port 9990.
Only the CLI is installed — not the full WildFly server.

Commands executed:

Code
wget https://github.com/wildfly/wildfly/releases/download/30.0.1.Final/wildfly-30.0.1.Final.tar.gz
tar -xvf wildfly-30.0.1.Final.tar.gz
sudo mv wildfly-30.0.1.Final /opt/wildfly-cli
After installation, the CLI binary will be available at:

Code
/opt/wildfly-cli/bin/jboss-cli.sh
Recommended screenshot name:  
27_11_wildfly_cli_installed_on_jenkins_master.png

27.12 — Test Remote Management Access from Jenkins Master
(English description + commands, як ти хочеш)

In this step, the Jenkins master verifies remote access to the WildFly management interface using the CLI installed earlier.
This confirms that the WildFly server is reachable over port 9990, and that the jenkins management user can authenticate successfully.

Commands executed:

Code
/opt/wildfly-cli/bin/jboss-cli.sh \
  --connect \
  --controller=13.48.29.172:9990 \
  --user=jenkins \
  --password=YOUR_PASSWORD
Inside CLI:

Code
:read-attribute(name=server-state)
quit
Expected output:

Code
"result" => "running"
Recommended screenshot name:  
27_12_wildfly_remote_cli_test.png

27.13 — Configure Jenkins for WildFly Deployment
(English description + commands, як ти хочеш)

In this step, Jenkins is configured to deploy .war artifacts to the WildFly server using the management API.
Jenkins will use the WildFly CLI installed earlier to perform automated deployments during CI/CD pipelines.

What we will configure:

Jenkins credentials for WildFly (jenkins / jenkins)

Jenkins job with build steps

Deployment command using CLI

Automatic undeploy + deploy

Verification step

🟩 Step 1 — Add Jenkins Credentials
(English description)

Jenkins needs credentials to authenticate to the WildFly management interface.
We create a username/password credential that will be used in pipeline scripts or freestyle jobs.

Actions performed in Jenkins UI:

Go to Manage Jenkins

Open Credentials

Select System → Global credentials

Add new credential:

Kind: Username with password

Username: jenkins

Password: jenkins

ID: wildfly-creds

Description: WildFly Management User

Recommended screenshot name:  
27_13_jenkins_credentials.png

27.14 — Jenkins Freestyle Job: Deploy WAR to WildFly
(English description)

In this step, a Jenkins Freestyle Job is created to automatically deploy a .war application to the WildFly server using the management API.
The job uses the WildFly CLI installed on the Jenkins master and the credentials created earlier.

Purpose
This job enables automated CI/CD deployment to the WildFly application server.
It performs undeploy (if the application already exists) and deploys the new .war artifact.

Jenkins Configuration Steps
Create a new Jenkins Freestyle Project named wildfly-deploy.

(Optional) Configure Source Code Management if the .war file is stored in Git.

Add a Build Step → Execute Shell.

Insert the following deployment script:

Code
/opt/wildfly-cli/bin/jboss-cli.sh \
  --connect \
  --controller=13.48.29.172:9990 \
  --user=jenkins \
  --password=jenkins \
  --command="undeploy myapp.war --keep-content"

/opt/wildfly-cli/bin/jboss-cli.sh \
  --connect \
  --controller=13.48.29.172:9990 \
  --user=jenkins \
  --password=jenkins \
  --command="deploy /var/lib/jenkins/workspace/wildfly-deploy/target/myapp.war --force"
Expected Result
The job successfully connects to WildFly, undeploys the previous version, and deploys the new .war file.

Recommended screenshot names:

27_14_jenkins_freestyle_config.png

27.15 — Run Jenkins Job and Verify Deployment on WildFly
(English description)

In this step, the Jenkins Freestyle Job created earlier is executed to deploy the .war application to the WildFly server.
The job uses the WildFly CLI to perform undeploy (if necessary) and deploy the new application version.

Execution Steps
Open the Jenkins job wildfly-deploy.

Click Build Now to start the deployment process.

Open the build console output to verify that:

Jenkins successfully connects to WildFly

The previous deployment is removed (if present)

The new .war file is deployed

No errors occur during CLI execution

Expected Console Output
Successful CLI connection

undeploy executed (or message that deployment does not exist)

deploy executed with --force

Build marked as SUCCESS

Verification on WildFly
After the job completes, the deployed application should be accessible at:

Code
http://13.48.29.172:8080/myapp/
Recommended screenshot names:

27_15_jenkins_build_now.png