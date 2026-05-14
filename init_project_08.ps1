# ============================================
# init_project_08.ps1 — PART 1 / 5
# Project: project-08-terraform-ansible-cicd
# ============================================

$projectRoot = Join-Path $PSScriptRoot "project-08-terraform-ansible-cicd"
Write-Host "Creating project: $projectRoot" -ForegroundColor Cyan

# Create root folder
New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null

# --------------------------------------------
# Helper: write UTF-8 without BOM
# --------------------------------------------
function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Content)
    [System.IO.File]::WriteAllBytes($Path, $bytes)
}

# --------------------------------------------
# Helper: convert CRLF → LF
# --------------------------------------------
function Convert-ToLF {
    param([string]$Path)
    $content = Get-Content $Path -Raw
    $content = $content.Replace("`r`n", "`n")
    Set-Content -Path $Path -Value $content -NoNewline -Encoding utf8
}

# --------------------------------------------
# Create directory structure
# --------------------------------------------
$folders = @(
    "$projectRoot\terraform",
    "$projectRoot\terraform\templates",
    "$projectRoot\terraform\generated",
    "$projectRoot\ansible",
    "$projectRoot\ansible\roles",
    "$projectRoot\ansible\roles\jenkins_master\tasks",
    "$projectRoot\ansible\roles\jenkins_slave\tasks",
    "$projectRoot\ansible\roles\wildfly_server\tasks",
    "$projectRoot\ansible\roles\apache\tasks",
    "$projectRoot\ansible\roles\ssl\tasks",
    "$projectRoot\ansible\roles\backup\tasks",
    "$projectRoot\ansible\group_vars",
    "$projectRoot\scripts",
    "$projectRoot\images"
)

foreach ($f in $folders) {
    New-Item -ItemType Directory -Force -Path $f | Out-Null
}

# --------------------------------------------
# .gitignore
# --------------------------------------------
$gitignore = @"
# Terraform
.terraform/
terraform.tfstate
terraform.tfstate.backup
crash.log

# Ansible
*.retry

# OS
Thumbs.db
.DS_Store

# Python
venv/

# Logs
*.log
"@
Write-Utf8NoBom "$projectRoot\.gitignore" $gitignore

# --------------------------------------------
# README.md
# --------------------------------------------
$readme = @"
# Project 08 – Terraform + Ansible CI/CD Infrastructure (Jenkins + WildFly on AWS)

This project provisions a complete CI/CD infrastructure on AWS using Terraform and Ansible:

- Jenkins Master (Apache + Jenkins + SSL + AWS CLI)
- Jenkins Slave (JDK + SSH)
- WildFly Web Server (Apache + SSL)
- S3 bucket for JENKINS_HOME backup/restore

Terraform → infrastructure  
Ansible → configuration  
"@
Write-Utf8NoBom "$projectRoot\README.md" $readme

# --------------------------------------------
# Terraform: provider.tf
# --------------------------------------------
$providerTf = @"
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
"@
Write-Utf8NoBom "$projectRoot\terraform\provider.tf" $providerTf

# --------------------------------------------
# Terraform: variables.tf
# --------------------------------------------
$variablesTf = @"
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name"
  type        = string
  default     = "HrSolution_Key_Pair"
}

variable "jenkins_s3_bucket_name" {
  description = "S3 bucket name for JENKINS_HOME backup"
  type        = string
  default     = "jenkins-home-backup-bucket-08"
}
"@
Write-Utf8NoBom "$projectRoot\terraform\variables.tf" $variablesTf

# --------------------------------------------
# Terraform: main.tf (AMI + VPC)
# --------------------------------------------
$mainTf = @"
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}
"@
Write-Utf8NoBom "$projectRoot\terraform\main.tf" $mainTf
# ============================================
# init_project_08.ps1 — PART 2 / 5
# Terraform: SG, EC2, S3, outputs, inventory
# ============================================

# --------------------------------------------
# Terraform: security-groups.tf
# --------------------------------------------
$sgTf = @"
resource "aws_security_group" "jenkins_master_sg" {
  name   = "jenkins-master-sg-08"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-master-sg-08"
  }
}

resource "aws_security_group" "jenkins_slave_sg" {
  name   = "jenkins-slave-sg-08"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-slave-sg-08"
  }
}

resource "aws_security_group" "wildfly_sg" {
  name   = "wildfly-sg-08"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9990
    to_port     = 9990
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wildfly-sg-08"
  }
}
"@
Write-Utf8NoBom "$projectRoot\terraform\security-groups.tf" $sgTf

# --------------------------------------------
# Terraform: keypair.tf
# --------------------------------------------
$keypairTf = @"
data "aws_key_pair" "existing" {
  key_name = var.key_name
}
"@
Write-Utf8NoBom "$projectRoot\terraform\keypair.tf" $keypairTf

# --------------------------------------------
# Terraform: s3.tf
# --------------------------------------------
$s3Tf = @"
resource "aws_s3_bucket" "jenkins_home" {
  bucket = var.jenkins_s3_bucket_name

  tags = {
    Name = "jenkins-home-backup-08"
  }
}
"@
Write-Utf8NoBom "$projectRoot\terraform\s3.tf" $s3Tf

# --------------------------------------------
# Terraform: ec2-master.tf
# --------------------------------------------
$masterTf = @"
resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]

  tags = {
    Name = "jenkins-master-08"
    Role = "jenkins_master"
  }
}
"@
Write-Utf8NoBom "$projectRoot\terraform\ec2-master.tf" $masterTf

# --------------------------------------------
# Terraform: ec2-slave.tf
# --------------------------------------------
$slaveTf = @"
resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_slave_sg.id]

  tags = {
    Name = "jenkins-slave-08"
    Role = "jenkins_slave"
  }
}
"@
Write-Utf8NoBom "$projectRoot\terraform\ec2-slave.tf" $slaveTf

# --------------------------------------------
# Terraform: ec2-wildfly.tf
# --------------------------------------------
$wildflyTf = @"
resource "aws_instance" "wildfly_server" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.wildfly_sg.id]

  tags = {
    Name = "wildfly-server-08"
    Role = "wildfly_server"
  }
}
"@
Write-Utf8NoBom "$projectRoot\terraform\ec2-wildfly.tf" $wildflyTf

# --------------------------------------------
# Terraform: outputs.tf
# --------------------------------------------
$outputsTf = @"
output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_slave_ip" {
  value = aws_instance.jenkins_slave.public_ip
}

output "wildfly_ip" {
  value = aws_instance.wildfly_server.public_ip
}

output "jenkins_s3_bucket_name" {
  value = aws_s3_bucket.jenkins_home.bucket
}
"@
Write-Utf8NoBom "$projectRoot\terraform\outputs.tf" $outputsTf

# --------------------------------------------
# Terraform: templates/inventory.tpl
# --------------------------------------------
$inventoryTpl = @"
[jenkins_master]
\${jenkins_master_ip}

[jenkins_slave]
\${jenkins_slave_ip}

[wildfly]
\${wildfly_ip}
"@
Write-Utf8NoBom "$projectRoot\terraform\templates\inventory.tpl" $inventoryTpl

# --------------------------------------------
# Terraform: inventory-gen.tf
# --------------------------------------------
$inventoryGenTf = @"
locals {
  inventory_content = templatefile("${path.module}/templates/inventory.tpl", {
    jenkins_master_ip = aws_instance.jenkins_master.public_ip
    jenkins_slave_ip  = aws_instance.jenkins_slave.public_ip
    wildfly_ip        = aws_instance.wildfly_server.public_ip
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory_content
  filename = "${path.module}/generated/inventory.ini"
}
"@
Write-Utf8NoBom "$projectRoot\terraform\inventory-gen.tf" $inventoryGenTf
# ============================================
# init_project_08.ps1 — PART 3 / 5
# Ansible: playbook, group_vars, roles
# ============================================

# --------------------------------------------
# Ansible: group_vars
# --------------------------------------------
$gvMaster = @"
jenkins_s3_bucket_name: jenkins-home-backup-bucket-08
jenkins_home_path: /var/lib/jenkins
"@
Write-Utf8NoBom "$projectRoot\ansible\group_vars\jenkins_master.yml" $gvMaster

$gvSlave = @"
java_package: openjdk-21-jdk
"@
Write-Utf8NoBom "$projectRoot\ansible\group_vars\jenkins_slave.yml" $gvSlave

$gvWildfly = @"
wildfly_version: 30.0.1.Final
wildfly_install_dir: /opt/wildfly
"@
Write-Utf8NoBom "$projectRoot\ansible\group_vars\wildfly.yml" $gvWildfly

# --------------------------------------------
# Ansible: playbook.yml
# --------------------------------------------
$playbook = @"
- hosts: jenkins_master
  become: yes
  roles:
    - apache
    - ssl
    - jenkins_master
    - backup

- hosts: jenkins_slave
  become: yes
  roles:
    - jenkins_slave

- hosts: wildfly
  become: yes
  roles:
    - apache
    - ssl
    - wildfly_server
"@
Write-Utf8NoBom "$projectRoot\ansible\playbook.yml" $playbook

# --------------------------------------------
# Ansible role: apache/tasks/main.yml
# --------------------------------------------
$apacheTasks = @"
---
# Install and configure Apache HTTP Server

- name: Install Apache
  apt:
    name: apache2
    state: present
    update_cache: yes

- name: Ensure Apache is enabled and running
  service:
    name: apache2
    state: started
    enabled: yes
"@
Write-Utf8NoBom "$projectRoot\ansible\roles\apache\tasks\main.yml" $apacheTasks

# --------------------------------------------
# Ansible role: ssl/tasks/main.yml (self-signed)
# --------------------------------------------
$sslTasks = @"
---
# Generate self-signed SSL certificate for Apache

- name: Install OpenSSL
  apt:
    name: openssl
    state: present
    update_cache: yes

- name: Create SSL directory
  file:
    path: /etc/apache2/ssl
    state: directory
    mode: '0755'

- name: Generate self-signed certificate
  command: >
    openssl req -x509 -nodes -days 365
    -subj "/C=DE/ST=Saarland/L=Saarbruecken/O=DevOps/OU=IT/CN=example.local"
    -newkey rsa:2048
    -keyout /etc/apache2/ssl/apache-selfsigned.key
    -out /etc/apache2/ssl/apache-selfsigned.crt
  args:
    creates: /etc/apache2/ssl/apache-selfsigned.crt

- name: Enable SSL module
  command: a2enmod ssl
  register: ssl_mod
  changed_when: ssl_mod.rc == 0
  failed_when: false
  notify: Restart Apache

- name: Enable default SSL site
  command: a2ensite default-ssl
  register: ssl_site
  changed_when: ssl_site.rc == 0
  failed_when: false
  notify: Restart Apache

- name: Ensure Apache is running with SSL
  service:
    name: apache2
    state: started
    enabled: yes

- name: Flush handlers
  meta: flush_handlers

"@
Write-Utf8NoBom "$projectRoot\ansible\roles\ssl\tasks\main.yml" $sslTasks

# --------------------------------------------
# Ansible role: jenkins_master/tasks/main.yml
# --------------------------------------------
$jenkinsMasterTasks = @"
---
# Install Java, Jenkins, AWS CLI and prepare JENKINS_HOME restore

- name: Install Java and required packages
  apt:
    name:
      - openjdk-21-jdk
      - curl
      - gnupg
      - ca-certificates
      - awscli
    state: present
    update_cache: yes

- name: Add Jenkins key and repository
  shell: |
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  args:
    creates: /etc/apt/sources.list.d/jenkins.list

- name: Install Jenkins
  apt:
    name: jenkins
    state: present
    update_cache: yes

- name: Ensure Jenkins service is enabled and started
  service:
    name: jenkins
    state: started
    enabled: yes

- name: Ensure JENKINS_HOME directory exists
  file:
    path: "{{ jenkins_home_path }}"
    state: directory
    owner: jenkins
    group: jenkins
    mode: '0755'

- name: Restore JENKINS_HOME from S3 if archive exists
  shell: |
    if aws s3 ls s3://{{ jenkins_s3_bucket_name }}/jenkins_home.tar.gz >/dev/null 2>&1; then
      echo "Found existing JENKINS_HOME backup in S3, restoring..."
      aws s3 cp s3://{{ jenkins_s3_bucket_name }}/jenkins_home.tar.gz /tmp/jenkins_home.tar.gz
      systemctl stop jenkins
      tar -xzf /tmp/jenkins_home.tar.gz -C /
      chown -R jenkins:jenkins {{ jenkins_home_path }}
      systemctl start jenkins
    else
      echo "No existing JENKINS_HOME backup found in S3, skipping restore."
    fi
  args:
    executable: /bin/bash
"@
Write-Utf8NoBom "$projectRoot\ansible\roles\jenkins_master\tasks\main.yml" $jenkinsMasterTasks

# --------------------------------------------
# Ansible role: backup/tasks/main.yml
# --------------------------------------------
$backupTasks = @"
---
# Configure cron-based backup of JENKINS_HOME to S3

- name: Install AWS CLI (ensure)
  apt:
    name: awscli
    state: present
    update_cache: yes

- name: Deploy backup script
  copy:
    src: ../../scripts/backup_jenkins_home.sh
    dest: /usr/local/bin/backup_jenkins_home.sh
    mode: '0755'

- name: Configure cron job for JENKINS_HOME backup
  cron:
    name: "JENKINS_HOME backup to S3"
    user: root
    minute: "0"
    hour: "*/6"
    job: "/usr/local/bin/backup_jenkins_home.sh {{ jenkins_home_path }} {{ jenkins_s3_bucket_name }} >> /var/log/jenkins_backup.log 2>&1"
"@
Write-Utf8NoBom "$projectRoot\ansible\roles\backup\tasks\main.yml" $backupTasks

# --------------------------------------------
# Ansible role: jenkins_slave/tasks/main.yml
# --------------------------------------------
$jenkinsSlaveTasks = @"
---
# Prepare Jenkins Slave: Java + jenkins user + SSH

- name: Install Java
  apt:
    name: "{{ java_package }}"
    state: present
    update_cache: yes

- name: Create jenkins user
  user:
    name: jenkins
    shell: /bin/bash
    create_home: yes

- name: Ensure .ssh directory exists
  file:
    path: /home/jenkins/.ssh
    state: directory
    owner: jenkins
    group: jenkins
    mode: '0700'

# NOTE: authorized_keys should be managed manually or via separate secure mechanism
"@
Write-Utf8NoBom "$projectRoot\ansible\roles\jenkins_slave\tasks\main.yml" $jenkinsSlaveTasks

# --------------------------------------------
# Ansible role: wildfly_server/tasks/main.yml
# --------------------------------------------
$wildflyTasks = @"
---
# Install Java, WildFly and configure as a service

- name: Install Java and tools
  apt:
    name:
      - openjdk-21-jdk
      - wget
      - unzip
    state: present
    update_cache: yes

- name: Download WildFly archive
  get_url:
    url: "https://github.com/wildfly/wildfly/releases/download/{{ wildfly_version }}/wildfly-{{ wildfly_version }}.zip"
    dest: /tmp/wildfly-{{ wildfly_version }}.zip

- name: Unpack WildFly
  unarchive:
    src: /tmp/wildfly-{{ wildfly_version }}.zip
    dest: /opt
    remote_src: yes
    creates: "/opt/wildfly-{{ wildfly_version }}"

- name: Symlink WildFly directory
  file:
    src: "/opt/wildfly-{{ wildfly_version }}"
    dest: "{{ wildfly_install_dir }}"
    state: link
    force: yes

- name: Create wildfly user
  user:
    name: wildfly
    system: yes
    shell: /usr/sbin/nologin

- name: Set ownership on WildFly directory
  file:
    path: "{{ wildfly_install_dir }}"
    state: directory
    owner: wildfly
    group: wildfly
    recurse: yes

- name: Create systemd service for WildFly
  copy:
    dest: /etc/systemd/system/wildfly.service
    content: |
      [Unit]
      Description=WildFly Application Server
      After=network.target

      [Service]
      Type=simple
      User=wildfly
      Group=wildfly
      ExecStart={{ wildfly_install_dir }}/bin/standalone.sh -b 0.0.0.0
      Restart=always

      [Install]
      WantedBy=multi-user.target
  notify: Restart WildFly

- name: Enable and start WildFly
  systemd:
    name: wildfly
    enabled: yes
    state: started
"@
Write-Utf8NoBom "$projectRoot\ansible\roles\wildfly_server\tasks\main.yml" $wildflyTasks
# ============================================
# init_project_08.ps1 — PART 4 / 5
# Bash scripts: backup_jenkins_home.sh, restore_jenkins_home.sh
# ============================================

# --------------------------------------------
# scripts/backup_jenkins_home.sh
# --------------------------------------------
$backupScriptPath = "$projectRoot\scripts\backup_jenkins_home.sh"
New-Item -ItemType File -Force -Path $backupScriptPath | Out-Null

Add-Content -Path $backupScriptPath -Value '#!/usr/bin/env bash'
Add-Content -Path $backupScriptPath -Value 'set -euo pipefail'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'LOG_FILE="/var/log/jenkins_backup.log"'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'log() {'
Add-Content -Path $backupScriptPath -Value '  local level="$1"; shift'
Add-Content -Path $backupScriptPath -Value '  local msg="$*"'
Add-Content -Path $backupScriptPath -Value '  local ts="$(date -u +%Y-%m-%dT%H:%M:%S)"'
Add-Content -Path $backupScriptPath -Value '  echo "[$ts] [$level] $msg" | tee -a "$LOG_FILE"'
Add-Content -Path $backupScriptPath -Value '}'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'log_info()  { log "INFO"  "$@"; }'
Add-Content -Path $backupScriptPath -Value 'log_warn()  { log "WARN"  "$@"; }'
Add-Content -Path $backupScriptPath -Value 'log_error() { log "ERROR" "$@"; }'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'if [ "$#" -ne 2 ]; then'
Add-Content -Path $backupScriptPath -Value '  echo "Usage: $0 /var/lib/jenkins jenkins-home-backup-bucket-08"'
Add-Content -Path $backupScriptPath -Value '  exit 1'
Add-Content -Path $backupScriptPath -Value 'fi'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'JENKINS_HOME="$1"'
Add-Content -Path $backupScriptPath -Value 'S3_BUCKET="$2"'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'if [ ! -d "$JENKINS_HOME" ]; then'
Add-Content -Path $backupScriptPath -Value '  log_error "JENKINS_HOME directory does not exist: $JENKINS_HOME"'
Add-Content -Path $backupScriptPath -Value '  exit 1'
Add-Content -Path $backupScriptPath -Value 'fi'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'if ! command -v aws >/dev/null 2>&1; then'
Add-Content -Path $backupScriptPath -Value '  log_error "aws CLI is not installed"'
Add-Content -Path $backupScriptPath -Value '  exit 1'
Add-Content -Path $backupScriptPath -Value 'fi'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'if ! aws s3 ls "s3://$S3_BUCKET" >/dev/null 2>&1; then'
Add-Content -Path $backupScriptPath -Value '  log_error "S3 bucket does not exist or is not accessible: $S3_BUCKET"'
Add-Content -Path $backupScriptPath -Value '  exit 1'
Add-Content -Path $backupScriptPath -Value 'fi'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'TS="$(date -u +%Y-%m-%dT%H-%M-%S)"'
Add-Content -Path $backupScriptPath -Value 'ARCHIVE="/tmp/jenkins_home_${TS}.tar.gz"'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'log_info "Starting backup of $JENKINS_HOME to S3 bucket $S3_BUCKET"'
Add-Content -Path $backupScriptPath -Value 'log_info "Creating archive $ARCHIVE"'
Add-Content -Path $backupScriptPath -Value 'tar -czf "$ARCHIVE" -C / "$(echo "$JENKINS_HOME" | sed "s|^/||")"'
Add-Content -Path $backupScriptPath -Value ''
Add-Content -Path $backupScriptPath -Value 'S3_OBJECT="s3://$S3_BUCKET/jenkins_home_${TS}.tar.gz"'
Add-Content -Path $backupScriptPath -Value 'log_info "Uploading archive to $S3_OBJECT"'
Add-Content -Path $backupScriptPath -Value 'if aws s3 cp "$ARCHIVE" "$S3_OBJECT"; then'
Add-Content -Path $backupScriptPath -Value '  log_info "Backup successfully uploaded to $S3_OBJECT"'
Add-Content -Path $backupScriptPath -Value '  rm -f "$ARCHIVE"'
Add-Content -Path $backupScriptPath -Value '  log_info "Temporary archive removed: $ARCHIVE"'
Add-Content -Path $backupScriptPath -Value '  exit 0'
Add-Content -Path $backupScriptPath -Value 'else'
Add-Content -Path $backupScriptPath -Value '  log_error "Failed to upload backup to S3"'
Add-Content -Path $backupScriptPath -Value '  exit 1'
Add-Content -Path $backupScriptPath -Value 'fi'

Convert-ToLF $backupScriptPath

# --------------------------------------------
# scripts/restore_jenkins_home.sh
# --------------------------------------------
$restoreScriptPath = "$projectRoot\scripts\restore_jenkins_home.sh"
New-Item -ItemType File -Force -Path $restoreScriptPath | Out-Null

Add-Content -Path $restoreScriptPath -Value '#!/usr/bin/env bash'
Add-Content -Path $restoreScriptPath -Value 'set -euo pipefail'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'LOG_FILE="/var/log/jenkins_backup.log"'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'log() {'
Add-Content -Path $restoreScriptPath -Value '  local level="$1"; shift'
Add-Content -Path $restoreScriptPath -Value '  local msg="$*"'
Add-Content -Path $restoreScriptPath -Value '  local ts="$(date -u +%Y-%m-%dT%H:%M:%S)"'
Add-Content -Path $restoreScriptPath -Value '  echo "[$ts] [$level] $msg" | tee -a "$LOG_FILE"'
Add-Content -Path $restoreScriptPath -Value '}'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'log_info()  { log "INFO"  "$@"; }'
Add-Content -Path $restoreScriptPath -Value 'log_warn()  { log "WARN"  "$@"; }'
Add-Content -Path $restoreScriptPath -Value 'log_error() { log "ERROR" "$@"; }'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'if [ "$#" -ne 3 ]; then'
Add-Content -Path $restoreScriptPath -Value '  echo "Usage: $0 /var/lib/jenkins jenkins-home-backup-bucket-08 jenkins_home_YYYY-MM-DDTHH-MM-SS.tar.gz"'
Add-Content -Path $restoreScriptPath -Value '  exit 1'
Add-Content -Path $restoreScriptPath -Value 'fi'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'JENKINS_HOME="$1"'
Add-Content -Path $restoreScriptPath -Value 'S3_BUCKET="$2"'
Add-Content -Path $restoreScriptPath -Value 'ARCHIVE_NAME="$3"'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'if [ ! -d "$JENKINS_HOME" ]; then'
Add-Content -Path $restoreScriptPath -Value '  log_error "JENKINS_HOME directory does not exist: $JENKINS_HOME"'
Add-Content -Path $restoreScriptPath -Value '  exit 1'
Add-Content -Path $restoreScriptPath -Value 'fi'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'if ! command -v aws >/dev/null 2>&1; then'
Add-Content -Path $restoreScriptPath -Value '  log_error "aws CLI is not installed"'
Add-Content -Path $restoreScriptPath -Value '  exit 1'
Add-Content -Path $restoreScriptPath -Value 'fi'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'S3_OBJECT="s3://$S3_BUCKET/$ARCHIVE_NAME"'
Add-Content -Path $restoreScriptPath -Value 'TMP_ARCHIVE="/tmp/jenkins_home_restore.tar.gz"'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'log_info "Restoring JENKINS_HOME from $S3_OBJECT to $JENKINS_HOME"'
Add-Content -Path $restoreScriptPath -Value 'if ! aws s3 cp "$S3_OBJECT" "$TMP_ARCHIVE"; then'
Add-Content -Path $restoreScriptPath -Value '  log_error "Failed to download archive from S3: $S3_OBJECT"'
Add-Content -Path $restoreScriptPath -Value '  exit 1'
Add-Content -Path $restoreScriptPath -Value 'fi'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'if systemctl is-active --quiet jenkins; then'
Add-Content -Path $restoreScriptPath -Value '  log_info "Stopping Jenkins service before restore"'
Add-Content -Path $restoreScriptPath -Value '  systemctl stop jenkins'
Add-Content -Path $restoreScriptPath -Value 'fi'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'log_info "Extracting archive to /"'
Add-Content -Path $restoreScriptPath -Value 'tar -xzf "$TMP_ARCHIVE" -C /'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'log_info "Setting ownership on $JENKINS_HOME"'
Add-Content -Path $restoreScriptPath -Value 'chown -R jenkins:jenkins "$JENKINS_HOME"'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'rm -f "$TMP_ARCHIVE"'
Add-Content -Path $restoreScriptPath -Value 'log_info "Temporary archive removed: $TMP_ARCHIVE"'
Add-Content -Path $restoreScriptPath -Value ''
Add-Content -Path $restoreScriptPath -Value 'log_info "Starting Jenkins service"'
Add-Content -Path $restoreScriptPath -Value 'systemctl start jenkins'
Add-Content -Path $restoreScriptPath -Value 'log_info "JENKINS_HOME restore completed successfully"'
Add-Content -Path $restoreScriptPath -Value 'exit 0'

Convert-ToLF $restoreScriptPath
# ============================================
# init_project_08.ps1 — PART 5 / 5
# Finalization
# ============================================

# Fix permissions for scripts
Set-ItemProperty -Path "$projectRoot\scripts\backup_jenkins_home.sh" -Name IsReadOnly -Value $false
Set-ItemProperty -Path "$projectRoot\scripts\restore_jenkins_home.sh" -Name IsReadOnly -Value $false

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host " Project project-08-terraform-ansible-cicd created successfully!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Terraform directory: $projectRoot\terraform" -ForegroundColor Cyan
Write-Host "Ansible directory:   $projectRoot\ansible" -ForegroundColor Cyan
Write-Host "Scripts directory:   $projectRoot\scripts" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd terraform" -ForegroundColor Yellow
Write-Host "2. terraform init" -ForegroundColor Yellow
Write-Host "3. terraform apply -auto-approve" -ForegroundColor Yellow
Write-Host "4. ansible-playbook -i terraform/generated/inventory.ini ../ansible/playbook.yml" -ForegroundColor Yellow
Write-Host ""
Write-Host "Done." -ForegroundColor Green
