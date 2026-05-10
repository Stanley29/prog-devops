# ================================
# Project Generator for:
# project-06-jenkins-ci-cd
# ================================

$projectRoot = Join-Path $PSScriptRoot "project-06-jenkins-ci-cd"
Write-Host "Creating project: $projectRoot"

# Create root folder
New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null

# Helper function: write UTF-8 without BOM
function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Content)
    [System.IO.File]::WriteAllBytes($Path, $bytes)
}

# Helper: convert CRLF → LF
function Convert-ToLF {
    param([string]$Path)
    $content = Get-Content $Path -Raw
    $content = $content.Replace("`r`n", "`n")
    Set-Content -Path $Path -Value $content -NoNewline -Encoding utf8
}

# ================================
# README.md
# ================================
$readme = @"
# Project 06 – Jenkins CI/CD with SSH Slaves and WildFly on AWS

This project provisions a Jenkins-based CI/CD pipeline on AWS EC2 using Terraform.

## Components

- Jenkins Master (EC2)
- Two Jenkins SSH Slaves (EC2)
- WildFly Deployment Server (EC2)
- Terraform IaC
- SSH-based deployment pipeline

## Structure

```
project-06-jenkins-ci-cd/
│── README.md
│── Jenkinsfile
│── jenkins-install.sh
│── slave-setup.sh
│── wildfly-install.sh
│── images/
└── terraform/
│── main.tf
│── variables.tf
│── outputs.tf
│── ec2-master.tf
│── ec2-slave1.tf
│── ec2-slave2.tf
│── ec2-wildfly.tf
│── security-groups.tf
└── keypair.tf
```


## Usage

cd terraform
terraform init
terraform apply


Terraform will output:

- Jenkins Master IP
- Slave #1 IP
- Slave #2 IP
- WildFly Server IP
"@

Write-Utf8NoBom "$projectRoot\README.md" $readme

# ================================
# Jenkinsfile
# ================================
$jenkinsfile = @"
pipeline {
    agent none

    environment {
        WILDFLY_HOST = credentials('wildfly_host')
        WILDFLY_USER = credentials('wildfly_user')
        WILDFLY_KEY  = credentials('wildfly_ssh_key')
    }

    stages {
        stage('Checkout') {
            agent { label 'slave-1' }
            steps {
                checkout scm
            }
        }

        stage('Build') {
            agent { label 'slave-1' }
            steps {
                echo "Build stage placeholder"
                sh 'ls -la'
            }
        }

        stage('Deploy to WildFly') {
            agent { label 'slave-2' }
            steps {
                echo "Deploying to WildFly"
                sh """
                echo "Example deploy step"
                # scp -i $WILDFLY_KEY target/myapp.war ${WILDFLY_USER}@${WILDFLY_HOST}:/opt/wildfly/standalone/deployments/
                """

            }
        }
    }
}
"@

Write-Utf8NoBom "$projectRoot\Jenkinsfile" $jenkinsfile

# ================================
# Shell scripts (.sh)
# ================================
$jenkinsInstall = @"
#!/usr/bin/env bash
set -e

apt-get update -y
apt-get install -y fontconfig openjdk-17-jdk curl

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ \
  | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update -y
apt-get install -y jenkins

systemctl enable jenkins
systemctl start jenkins
"@

$slaveSetup = @"
#!/usr/bin/env bash
set -e

apt-get update -y
apt-get install -y openjdk-17-jdk git
"@

$wildflyInstall = @"
#!/usr/bin/env bash
set -e

WILDFLY_VERSION=30.0.0.Final
INSTALL_DIR=/opt

apt-get update -y
apt-get install -y openjdk-17-jdk wget unzip

cd /tmp
wget https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.zip
unzip wildfly-$WILDFLY_VERSION.zip -d $INSTALL_DIR
mv $INSTALL_DIR/wildfly-$WILDFLY_VERSION $INSTALL_DIR/wildfly

useradd -r -s /bin/false wildfly || true
chown -R wildfly:wildfly $INSTALL_DIR/wildfly

cat > /etc/systemd/system/wildfly.service << EOF
[Unit]
Description=WildFly Application Server
After=network.target

[Service]
Type=simple
User=wildfly
Group=wildfly
ExecStart=/opt/wildfly/bin/standalone.sh -b 0.0.0.0
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable wildfly
systemctl start wildfly
"@

Write-Utf8NoBom "$projectRoot\jenkins-install.sh" $jenkinsInstall
Write-Utf8NoBom "$projectRoot\slave-setup.sh" $slaveSetup
Write-Utf8NoBom "$projectRoot\wildfly-install.sh" $wildflyInstall

# Convert to LF
Convert-ToLF "$projectRoot\jenkins-install.sh"
Convert-ToLF "$projectRoot\slave-setup.sh"
Convert-ToLF "$projectRoot\wildfly-install.sh"

# ================================
# images/
# ================================
New-Item -ItemType Directory -Force -Path "$projectRoot\images" | Out-Null

# ================================
# Terraform files
# ================================
$tfPath = "$projectRoot\terraform"
New-Item -ItemType Directory -Force -Path $tfPath | Out-Null

# main.tf
$mainTf = @"
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
"@
Write-Utf8NoBom "$tfPath\main.tf" $mainTf

# variables.tf
$variablesTf = @"
variable "aws_region" {
  default = "eu-north-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "HrSolution_Key_Pair"
}
"@
Write-Utf8NoBom "$tfPath\variables.tf" $variablesTf

# outputs.tf
$outputsTf = @"
output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "slave1_ip" {
  value = aws_instance.jenkins_slave1.public_ip
}

output "slave2_ip" {
  value = aws_instance.jenkins_slave2.public_ip
}

output "wildfly_ip" {
  value = aws_instance.wildfly.public_ip
}
"@
Write-Utf8NoBom "$tfPath\outputs.tf" $outputsTf

# security-groups.tf
$sgTf = @"
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "jenkins_master_sg" {
  name = "jenkins-master-sg"
  vpc_id = data.aws_vpc.default.id

  ingress { from_port = 22 to_port = 22 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 8080 to_port = 8080 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_security_group" "jenkins_slaves_sg" {
  name = "jenkins-slaves-sg"
  vpc_id = data.aws_vpc.default.id

  ingress { from_port = 22 to_port = 22 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_security_group" "wildfly_sg" {
  name = "wildfly-sg"
  vpc_id = data.aws_vpc.default.id

  ingress { from_port = 22 to_port = 22 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 8080 to_port = 8080 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 9990 to_port = 9990 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}
"@
Write-Utf8NoBom "$tfPath\security-groups.tf" $sgTf

# keypair.tf
$keypairTf = @"
data "aws_key_pair" "existing" {
  key_name = var.key_name
}
"@
Write-Utf8NoBom "$tfPath\keypair.tf" $keypairTf

# ec2-master.tf
$masterTf = @"
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami = data.aws_ami.ubuntu_2204.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]

  user_data = file("${path.module}/../jenkins-install.sh")

  tags = {
    Name = "jenkins-master"
  }
}
"@
Write-Utf8NoBom "$tfPath\ec2-master.tf" $masterTf

# ec2-slave1.tf
$slave1Tf = @"
resource "aws_instance" "jenkins_slave1" {
  ami = data.aws_ami.ubuntu_2204.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_slaves_sg.id]

  user_data = file("${path.module}/../slave-setup.sh")

  tags = {
    Name = "jenkins-slave-1"
  }
}
"@
Write-Utf8NoBom "$tfPath\ec2-slave1.tf" $slave1Tf

# ec2-slave2.tf
$slave2Tf = @"
resource "aws_instance" "jenkins_slave2" {
  ami = data.aws_ami.ubuntu_2204.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_slaves_sg.id]

  user_data = file("${path.module}/../slave-setup.sh")

  tags = {
    Name = "jenkins-slave-2"
  }
}
"@
Write-Utf8NoBom "$tfPath\ec2-slave2.tf" $slave2Tf

# ec2-wildfly.tf
$wildflyTf = @"
resource "aws_instance" "wildfly" {
  ami = data.aws_ami.ubuntu_2204.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.wildfly_sg.id]

  user_data = file("${path.module}/../wildfly-install.sh")

  tags = {
    Name = "wildfly-server"
  }
}
"@
Write-Utf8NoBom "$tfPath\ec2-wildfly.tf" $wildflyTf

Write-Host "Project created successfully."
