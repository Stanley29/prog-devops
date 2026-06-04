# Main project folder name
$PROJECT = "project-16-terraform-k8s-helm-autodeploy"

Write-Host "Creating project structure: $PROJECT"

# Main folder
New-Item -ItemType Directory -Path $PROJECT -Force | Out-Null

# Terraform structure
New-Item -ItemType Directory -Path "$PROJECT/terraform" -Force | Out-Null

New-Item -ItemType File -Path "$PROJECT/terraform/main.tf" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/terraform/provider.tf" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/terraform/variables.tf" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/terraform/outputs.tf" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/terraform/terraform.tfvars" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/terraform/user_data.sh" -Force | Out-Null

# Helm structure
New-Item -ItemType Directory -Path "$PROJECT/helm/carservice-chart/templates" -Force | Out-Null

New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/Chart.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/values.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/README.md" -Force | Out-Null

# Templates
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/namespace.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/mssql-deployment.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/mssql-service.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/pvc.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/backend-deployment.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/backend-service.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/init-db-job.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/init-sql-configmap.yaml" -Force | Out-Null
New-Item -ItemType File -Path "$PROJECT/helm/carservice-chart/templates/secrets.yaml" -Force | Out-Null

# Main README
New-Item -ItemType File -Path "$PROJECT/README.md" -Force | Out-Null

Write-Host "Done! Project structure created successfully."
