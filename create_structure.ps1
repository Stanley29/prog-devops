# Create main project directory
New-Item -ItemType Directory -Path "project-07-terraform" -Force | Out-Null
Set-Location "project-07-terraform"

# Create Terraform root files
New-Item -ItemType File -Name "main.tf" -Force | Out-Null
New-Item -ItemType File -Name "variables.tf" -Force | Out-Null
New-Item -ItemType File -Name "outputs.tf" -Force | Out-Null

# Create EC2 definition files
New-Item -ItemType File -Name "ec2-master.tf" -Force | Out-Null
New-Item -ItemType File -Name "ec2-slave.tf" -Force | Out-Null
New-Item -ItemType File -Name "ec2-web.tf" -Force | Out-Null

# Create networking & IAM files
New-Item -ItemType File -Name "security-groups.tf" -Force | Out-Null
New-Item -ItemType File -Name "iam.tf" -Force | Out-Null
New-Item -ItemType File -Name "s3.tf" -Force | Out-Null

# Create user-data directory and scripts
New-Item -ItemType Directory -Name "user-data" -Force | Out-Null
New-Item -ItemType File -Path "user-data/master.sh" -Force | Out-Null
New-Item -ItemType File -Path "user-data/slave.sh" -Force | Out-Null
New-Item -ItemType File -Path "user-data/web.sh" -Force | Out-Null

# Create images directory for screenshots
New-Item -ItemType Directory -Name "images" -Force | Out-Null

# Create README
New-Item -ItemType File -Name "README.md" -Force | Out-Null

Write-Host "Terraform project structure created successfully!"
