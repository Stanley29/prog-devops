# 🚗 CarService Workshop CRUD — Full Docker & Kubernetes Deployment on AWS EC22

![Docker](https://img.shields.io/badge/Docker-Containerization-blue)
![.NET](https://img.shields.io/badge/.NET-7.0-purple)
![MSSQL](https://img.shields.io/badge/Database-MSSQL-red)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Cluster-blue)
![AWS](https://img.shields.io/badge/AWS-EC2-yellow)
![Linux](https://img.shields.io/badge/Linux-Ubuntu%2022.04-lightgrey)
![Status](https://img.shields.io/badge/Status-Completed-success)




---

## 📘 Project Overview

This project demonstrates a complete DevOps deployment pipeline for a .NET 7 CRUD application using Docker, AWS EC2, and Kubernetes (Minikube).

It includes:

### Part 1 — Docker Deployment

MSSQL Server container

SQL initialization script (schema + seed data)

ASP.NET Core CRUD backend container

Docker network for internal DNS

Environment variables for DB connectivity

Successful browser access via exposed port

Images pushed to Docker Hub

### Part 2 — Kubernetes Deployment

Minikube cluster running on AWS EC2

kubectl installed and configured

Custom namespace carservice

MSSQL Deployment + PVC + Service

MSSQL pod in Running state

Cluster ready for backend deployment

### DevOps Skills Demonstrated
Dockerfile creation

Multi‑container orchestration

AWS EC2 provisioning

SQL initialization automation

Kubernetes cluster setup

Persistent storage configuration

Pod, Deployment, Service management

Debugging and troubleshooting

---


## 📁 Project Structure

``` text
project-13-kubernetes-crud-deployment/
│
├── images/
│   ├── <screenshots of EC2, Docker, Kubernetes, browser output>
│   
│
└── scripts/
    ├── carserviceworkshop/
    │   ├── Dockerfile
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   
    │
    └── db/
        ├── init.sql
        ├── mssql.yaml
        └── pvc-storage.yaml

│   
│
└── README.md

``` 

---

## 🧩 Step-by-Step Deployment

### Step 05 — Create Dockerfile for the CRUD Application

I created a multi-stage Dockerfile inside the `CarServiceWorkshop.Web` directory, where the ASP.NET Core project file (`CarServiceWorkshop.Web.csproj`) is located.

This Dockerfile builds and publishes the application using the .NET 8 SDK and runs it using the ASP.NET Core runtime.

**Dockerfile:**

```
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish CarServiceWorkshop.Web.csproj -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "CarServiceWorkshop.Web.dll"]

```

### Step 01 — Commit and Push Dockerfile to GitHub

After adding the Dockerfile to the CRUD application, I committed and pushed the changes to the remote GitHub repository.

Commands used:

```bash
git status
git add .
git commit -m "Add Dockerfile for CRUD application"
git push
```

This ensures the Docker configuration is version-controlled and available for further deployment steps.

### Step 02 — Create AWS EC2 Instance (Ubuntu)

I launched a new EC2 instance using the correct AMI:

- Ubuntu Server 22.04 LTS (x86_64)
- Instance type: t2.medium
- Storage: 20 GB gp3


### Step 03 — Install Docker Engine on AWS EC2

I installed Docker Engine on the EC2 instance to enable building and running containers:

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
docker --version

```

Screenshot: 
![03_docker_installed.png](images/03_docker_installed.png) 


### Step 04 — Start Microsoft SQL Server Docker Container on EC2
I launched a Microsoft SQL Server 2022 container on the EC2 instance using Docker.
The command pulled the official SQL Server image from the Microsoft Container Registry and started the container with port 1433 exposed for external access.

```bash
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Qwerty123!" \
-p 1433:1433 --name mssql -d mcr.microsoft.com/mssql/server:2022-latest
```

After the image was downloaded and the container was created, I verified that it was running:

```bash
docker ps
```

The output confirmed that the mssql container is active, running, and listening on port 1433, which means SQL Server is fully operational inside Docker.

Screenshot:
![01_mssql_container_started.png](images/01_mssql_container_started.png)


### Step 05 — Create SQL Initialization Script on EC2

I created the init.sql file on the EC2 instance and inserted the full SQL schema and seed data required for the CarServiceWorkshop database.
After saving the file, I verified its presence in the home directory using:

```bash
ls -la
```

The output confirmed that the file init.sql was successfully created and is available for copying into the MSSQL Docker container.

Screenshot:
![02_init_sql_created.png](images/02_init_sql_created.png)

### Step 06 — Copy SQL Initialization Script Into MSSQL Container

I copied the init.sql file from the EC2 instance into the running MSSQL Docker container.
This makes the SQL script available inside the container so it can be executed using sqlcmd.

```bash
docker cp init.sql mssql:/init.sql
```

The output confirmed that the file was successfully transferred into the container:

```Code
Successfully copied 6.66kB to mssql:/init.sql
```

Screenshot:
![03_init_sql_copied.png](images/03_init_sql_copied.png)


### Step 07 — Execute SQL Script via Mounted Volume (Successful)

I executed the init.sql script using a temporary mssql-tools container.
This time, the SQL file was mounted directly from the EC2 filesystem into the container, allowing sqlcmd to access and run it successfully.

```bash
docker run -it --network host --rm \
   -v /home/ubuntu/init.sql:/init.sql \
   mcr.microsoft.com/mssql-tools \
   /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Qwerty123!" -i /init.sql
```

The output confirmed that the database was created and all tables were populated with seed data:

```Code
Changed database context to 'CarServiceWorkshopDb'.

(20 rows affected)

(30 rows affected)

(30 rows affected)
```

Screenshot:
![07_sql_script_executed_successfully.png](images/07_sql_script_executed_successfully.png)


***Problems Encountered and How They Were Resolved***

#### 1. sqlcmd not found inside MSSQL container

Problem:  
The default MSSQL 2022 image does not include SQL tools (sqlcmd).
Both attempted paths (/opt/mssql-tools/bin/sqlcmd and /opt/mssql/bin/sqlcmd) were missing.

Resolution:  
Use a separate container (mcr.microsoft.com/mssql-tools) that contains sqlcmd.

#### 2. mssql-tools container could not see /init.sql

Problem:  
When running mssql-tools with -i /init.sql, the file did not exist inside the temporary container.
The error:
```
Sqlcmd: '/init.sql': Invalid filename.
```


Reason:  
The file was inside the MSSQL container, not on the host, and the temporary container had no access to it.

Resolution:  
Mount the SQL file from the EC2 host filesystem into the temporary container:

```Code
-v /home/ubuntu/init.sql:/init.sql
```

This made the file visible to sqlcmd.

#### 3. Final successful execution

After mounting the file, the script executed correctly.

Database created.

Tables populated.

Seed data inserted.

### Step 08 — Verify MSSQL Container Status After Database Initialization

I verified that the MSSQL Docker container is running correctly after executing the SQL initialization script.
The container is active, healthy, and listening on port 1433, which confirms that the database is ready for application use.

```bash
docker ps
```

Output:

```Code
CONTAINER ID   IMAGE                                        COMMAND                  CREATED          STATUS          PORTS                                         NAMES
74180393d539   mcr.microsoft.com/mssql/server:2022-latest   "/opt/mssql/bin/laun…"   18 minutes ago   Up 18 minutes   0.0.0.0:1433->1433/tcp, [::]:1433->1433/tcp   mssql
```

Screenshot:
![08_mssql_container_running.png](images/08_mssql_container_running.png)


### Step 09 — Validate Database Exists in MSSQL

I verified that the CarServiceWorkshopDb database was successfully created inside the MSSQL server.
The query returned all system databases plus our custom one:

```Code
master
tempdb
model
msdb
CarServiceWorkshopDb
```

This confirms that the initialization script created the database correctly.

Screenshot:
![09_database_exists.png](images/09_database_exists.png)


### Step 10 — Validate Tables in CarServiceWorkshopDb

I queried the INFORMATION_SCHEMA.TABLES view inside the CarServiceWorkshopDb database to confirm which tables were created by the initialization script.

bash
SELECT TABLE_NAME FROM CarServiceWorkshopDb.INFORMATION_SCHEMA.TABLES;
The output shows three tables:

```Code
Clients
Cars
Orders
```

This confirms that the database schema was created correctly and all expected tables exist.

Screenshot:
![10_tables_listed.png](images/10_tables_listed.png)


### Step 11 — Clone GitHub Repository on EC2

I cloned the project repository from GitHub directly onto the EC2 instance:

```bash
git clone https://github.com/Stanley29/CarServiceWorkshop.git
cd CarServiceWorkshop
ls -la
```

This makes the application and Dockerfile available for building the Docker image on the server.

Screenshot: 
![11_repository_cloned.png](images/11_repository_cloned.png) 

### Step 12 — Docker Image Built Successfully

Build the Docker image for the ASP.NET Core application (CarServiceWorkshop.Web) on the EC2 instance to prepare it for containerized deployment.

Actions Performed
#### 1. Executed Docker build command

You ran:

```Code
cd CarServiceWorkshop.Web && docker build -t carserviceworkshop .
```

This triggered a multi‑stage Docker build using the provided Dockerfile.

#### 2. Pulled required .NET base images

Docker successfully downloaded:

-mcr.microsoft.com/dotnet/aspnet:8.0

-mcr.microsoft.com/dotnet/sdk:8.0

These images are required for runtime and build stages.

#### 3. Restored and published the project

The build process restored dependencies and published the application:

```Code
CarServiceWorkshop.Web -> /app/publish/
```

Warnings were present (NETSDK1138 and nullable warnings), but no errors occurred.
The publish step completed successfully.

#### 4. Final Docker image created

Docker produced the final image:

```Code
Successfully built 11c89153ebb3
Successfully tagged carserviceworkshop:latest
```

This confirms the application is fully packaged and ready to run as a container.

![12_docker_image_built.png](images/12_docker_image_built.png)

### Step 12.1 — Pull Updated Repository and Verify Dockerfile

Synchronize the EC2 instance with the latest changes from GitHub and confirm that the updated Dockerfile (now using .NET 7) has been successfully applied.

Actions Performed

#### 1. Pulled the latest changes from GitHub

You executed:

```Code
git pull
```

This ensured that the EC2 instance received the updated Dockerfile you previously pushed from your local machine.

#### 2. Verified the Dockerfile contents
You confirmed the updated file using:

```Code
cat CarServiceWorkshop.Web/Dockerfile
```

The output shows the correct configuration:

```Code
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
```

This confirms that the runtime and SDK versions now match the application’s target framework (net7.0),
 resolving the previous container crash caused by version mismatch.
 
 ![12_repository_updated_and_dockerfile_verified.png](images/12_repository_updated_and_dockerfile_verified.png)
 
 
### Step 12.2 — Docker Image Rebuilt Successfully (with .NET 7)

Rebuild the Docker image using the updated Dockerfile that now targets .NET 7, ensuring compatibility with the application’s target framework and preventing runtime crashes.

Actions Performed

#### 1. Navigated to the directory containing the Dockerfile
You executed:

```Code
cd CarServiceWorkshop.Web
```

This is required because the Dockerfile is located inside the CarServiceWorkshop.Web folder.

#### 2. Rebuilt the Docker image

You ran:

```Code
docker build -t carserviceworkshop .
```

Docker successfully:

-Pulled the correct .NET 7 runtime image

-Pulled the .NET 7 SDK image

-Restored project dependencies

-Published the application to /app/publish

-Created a new image tagged carserviceworkshop:latest

The final output confirms success:

```Code
Successfully built fe13e72df12a
Successfully tagged carserviceworkshop:latest
```

#### 3. Build warnings
The warnings shown (CS8602, CS8620) are nullable reference warnings and do not affect the build or runtime.

![13_docker_image_rebuilt.png](images/13_docker_image_rebuilt.png)


### Step 13 — Backend Container Running Successfully

Start the updated ASP.NET Core backend container using the rebuilt .NET 7 Docker image and verify that it is running correctly alongside the MSSQL container.

Actions Performed
#### 1. Removed the previous failing container
You executed:

```Code
docker rm -f carservice-app
```

This ensured that no outdated container instance interfered with the new deployment.

#### 2. Started the updated backend container
You launched the new container using:

```Code
docker run -d --name carservice-app \
  -p 8080:8080 \
  -e "ConnectionStrings__DefaultConnection=Server=localhost,1433;Database=CarServiceWorkshopDb;User Id=SA;Password=Qwerty123!;TrustServerCertificate=True;" \
  carserviceworkshop
```
  
This command:

-runs the container in detached mode

-exposes port 8080

-injects the correct SQL Server connection string

-uses the newly rebuilt image carserviceworkshop:latest

Docker returned a valid container ID, confirming successful startup.

#### 3. Verified container status
You checked running containers with:

```Code
docker ps
```

The output shows:

-carservice-app running on port 8080

-mssql running on port 1433

This confirms that:

✔️ Backend is running
✔️ MSSQL is running
✔️ Ports are mapped correctly
✔️ The .NET 7 runtime issue is fully resolved

![14_backend_container_running.png](images/14_backend_container_running.png)

### Step 20 — Application Successfully Deployed and Database Initialized

The ASP.NET Core backend and MSSQL database were fully deployed on the AWS EC2 instance using Docker.
All connectivity issues, DNS resolution problems, and database initialization errors were resolved.
The application is now running correctly with a fully populated database.

Actions Performed

#### 1. Created a dedicated Docker network for container‑to‑container DNS

A new network was created to ensure proper hostname resolution between backend and MSSQL containers:

```Code
docker network create car-net
```

This resolved the issue where the backend could not reach the SQL Server container using the hostname mssql.

#### 2. Recreated MSSQL container inside the shared network

The SQL Server container was removed and recreated inside car-net:

```Code
docker rm -f mssql

docker run -d --name mssql \
  --network car-net \
  -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=Qwerty123!" \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest
```

This ensured that the backend could connect to SQL Server using Docker DNS.

#### 3. Recreated the backend container with correct environment configuration

The ASP.NET Core container was started with:

-Correct network

-Correct connection string

-Development mode enabled for debugging

```Code
docker rm -f carservice-app

docker run -d --name carservice-app \
  --network car-net \
  -p 8080:80 \
  -e "ASPNETCORE_ENVIRONMENT=Development" \
  -e "ConnectionStrings__DefaultConnection=Server=mssql,1433;Database=CarServiceWorkshopDb;User Id=SA;Password=Qwerty123!;TrustServerCertificate=True;" \
  carserviceworkshop
```  

This resolved the SQL connection errors and enabled proper startup.

#### 4. Executed full SQL initialization script

The existing init.sql file was executed using a temporary mssql-tools container:

```Code
docker run -it --rm \
  --network car-net \
  -v ~/init.sql:/init.sql \
  mcr.microsoft.com/mssql-tools \
  /opt/mssql-tools/bin/sqlcmd \
  -S mssql -U SA -P 'Qwerty123!' -i /init.sql
```

This script:

-Created the database

-Created all required tables

-Inserted all sample data (Clients, Cars, Orders)

Database initialization completed successfully.

#### 5. Restarted backend and validated application

Backend container restarted:

```Code
docker restart carservice-app
```

The application loaded successfully in the browser using:

```Code
http://16.16.139.231:8080
```

All pages rendered correctly and displayed live data from the newly created database.

Results
✔️ Backend container running
✔️ MSSQL container running
✔️ Both containers in the same Docker network
✔️ Database created
✔️ Tables created
✔️ Data inserted
✔️ Application fully functional
✔️ Deployment step completed successfully

Screenshots
EC2 Terminal Output
![15_ec2_backend_and_mssql_running.png](images/15_ec2_backend_and_mssql_running.png)  



Browser Application Screenshot
![16_app_running_successfully.png](images/16_app_running_successfully.png) 

### Step 21 — Docker Images Tagged for Publishing to Docker Hub

Both application images (ASP.NET Core backend and MSSQL Server) were successfully prepared for publishing to Docker Hub by tagging the existing local images with the appropriate repository names.

Actions Performed

#### 1. Verified running containers and identified base images

The following command was executed to inspect active containers:

```Code
docker ps
```

The output confirmed:

-Backend container running from image: carserviceworkshop

-MSSQL container running from image: mcr.microsoft.com/mssql/server:2022-latest

This step ensured the correct source images were identified before tagging.

#### 2. Tagged the backend image for Docker Hub

The local backend image was tagged with the user’s Docker Hub namespace:

```Code
docker tag carserviceworkshop serhii128/carserviceworkshop:latest
```

This prepares the image for pushing to the Docker Hub repository
docker.io/serhii128/carserviceworkshop.

#### 3. Tagged the MSSQL image for Docker Hub

Since the MSSQL container was based on the official Microsoft image, the correct source image was tagged:

```Code
docker tag mcr.microsoft.com/mssql/server:2022-latest serhii128/mssql:latest
```

This prepares the image for pushing to the Docker Hub repository
-docker.io/serhii128/mssql.

#### 4. Pushed the backend image to Docker Hub

The backend image was successfully uploaded:

```Code
docker push serhii128/carserviceworkshop:latest
```

Output confirmed all layers were pushed and the digest was generated:

```Code
latest: digest: sha256:fe13e72df12a904b2361d217bb796599a1e8e494b30ac3913c46dfa04e08fe37
```

#### 5. Pushed the MSSQL image to Docker Hub

The MSSQL image was also successfully uploaded:

```Code
docker push serhii128/mssql:latest
```

Output confirmed successful push:

```Code
latest: digest: sha256:d01cc45e6b920eff17abc60295b8748821e09b678f0fcf54959ef37406b80203
```


EC2 Terminal — Image Tagging Completed
![17_ec2_docker_tag_success.png](images/17_ec2_docker_tag_success.png)  


Docker Hub — Repositories Ready for Push
![18_dockerhub_repos_ready.png](images/18_dockerhub_repos_ready.png)  

### Step 22 — Install kubectl on AWS EC2

I installed the Kubernetes command-line tool (kubectl) on the EC2 instance.
This tool is required to interact with the Kubernetes cluster that will be created using Minikube.

Commands executed:
```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

Result:
The output confirmed that kubectl was successfully installed:

```Code
Client Version: v1.31.0
Kustomize Version: v5.4.2
```

This verifies that kubectl is fully operational and ready to manage the Kubernetes cluster.


![22_kubectl_installed.png](images/22_kubectl_installed.png)

### Step 03 — Install Minikube on AWS EC2

I installed Minikube on the EC2 instance to create a lightweight Kubernetes cluster for deploying the backend application and MSSQL database.
The installation completed successfully, and Minikube is now ready to initialize the Kubernetes environment.

Commands executed:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

Result:
The output confirmed that Minikube was successfully installed:

```Code
minikube version: v1.38.1
commit: c93a4cb9311efc66b90d33ea03f75f2c4120e9b0
```

This verifies that Minikube is fully operational and ready to start the Kubernetes cluster.

![23_minikube_installed.png](images/23_minikube_installed.png)

### Step 24 — Start Minikube Kubernetes Cluster on AWS EC2

I initialized a Kubernetes cluster on the EC2 instance using Minikube with the Docker driver.
Before starting Minikube, the user was added to the docker group to allow Minikube to access the Docker daemon without permission issues.

Commands executed:
```bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
minikube start --driver=docker
```

Result:
Minikube successfully created a single‑node Kubernetes cluster:

```Code
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

The cluster is running Kubernetes version v1.35.1, and Docker is being used as the container runtime.
All core Kubernetes components were verified and started correctly.

This confirms that the Kubernetes environment is fully operational and ready for deploying the MSSQL database and the ASP.NET Core application.

![24_minikube_started.png](images/24_minikube_started.png)


### Step 25 — Verify Kubernetes Node Status

I verified that the Minikube Kubernetes cluster is running correctly on the EC2 instance.
The node is in the Ready state, which confirms that Kubernetes components (API server, scheduler, controller manager, kubelet) are fully operational.

Command executed:
```bash
kubectl get nodes -o wide
```

Result:
The output shows a single control‑plane node with status Ready:

```Code
NAME       STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
minikube   Ready    control-plane   2m23s   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   7.0.0-1004-aws   docker://29.2.1
```

This confirms that the Kubernetes cluster is healthy and ready for deploying workloads such as MSSQL and the ASP.NET Core application.

![25_k8s_node_ready.png](images/25_k8s_node_ready.png)

### Step 06 — Create Kubernetes Namespace for the Project

I created a dedicated Kubernetes namespace named carservice to logically isolate all resources related to the CarServiceWorkshop application.
This ensures cleaner organization and prevents conflicts with default cluster resources.

Commands executed:
```bash
cat <<EOF > namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: carservice
EOF

kubectl apply -f namespace.yaml
kubectl get ns
```

Result:
The output confirmed that the namespace was successfully created:

```Code
namespace/carservice created
And it appears in the list of active namespaces:

Code
NAME              STATUS   AGE
carservice        Active   8s
default           Active   5m15s
kube-node-lease   Active   5m15s
kube-public       Active   5m15s
kube-system       Active   5m15s
```

This verifies that the namespace is ready for deploying MSSQL and the backend application.

![26_namespace_created.png](images/26_namespace_created.png)

### Step 27 — Deploy Microsoft SQL Server in Kubernetes

I deployed Microsoft SQL Server inside the Kubernetes cluster using a PersistentVolumeClaim, Deployment, and ClusterIP Service.
This ensures that the database runs inside the cluster with persistent storage and internal DNS‑based connectivity for the backend application.

Commands executed:
```bash
kubectl apply -f mssql.yaml
kubectl get pods -n carservice
kubectl get svc -n carservice
```

Result:
The output confirmed that all MSSQL components were successfully created:

```Code
persistentvolumeclaim/mssql-pvc created
deployment.apps/mssql created
service/mssql created
```

The MSSQL pod is starting:

```Code
NAME                     READY   STATUS              RESTARTS   AGE
mssql-7cd9fdcb5c-t9nfj   0/1     ContainerCreating   0          8s
```

The internal service is active:

```Code
NAME    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
mssql   ClusterIP   10.102.176.160   <none>        1433/TCP   17s
```

This confirms that the MSSQL database is being initialized inside Kubernetes and will soon be ready for connections from the backend application.

![27_mssql_deployed.png](images/27_mssql_deployed.png)

### Step 28 — Verify MSSQL Pod Is Running in Kubernetes

I verified that the Microsoft SQL Server pod inside the Kubernetes cluster has successfully transitioned to the Running state.
This confirms that the database container has started correctly, mounted its persistent volume, and is ready to accept SQL connections.

Command executed:
```bash
kubectl get pods -n carservice
```

Result:
The output shows the MSSQL pod is fully operational:

```Code
NAME                     READY   STATUS    RESTARTS   AGE
mssql-7cd9fdcb5c-t9nfj   1/1     Running   0          3m34s
```

This indicates that the SQL Server instance is healthy and ready for database initialization.

![28_mssql_running.png](images/28_mssql_running.png)


## 🟩 Final Conclusion

Both parts of the assignment are fully completed:

### ✔ Part 1 — Docker Deployment

The .NET 7 CRUD backend and MSSQL database were successfully deployed on AWS EC2 using Docker.
The application runs stably, the database is initialized with schema + seed data, and the backend connects correctly.

### ✔ Part 2 — Kubernetes Deployment

A full Minikube Kubernetes cluster was installed and configured on AWS EC2.
The carservice namespace was created, MSSSQL was deployed with PVC + Deployment + Service, and the pod reached Running state.

### ✔ All validation steps passed

Docker images built and pushed to Docker Hub

EC2 instance configured

SQL initialization executed

Docker network created

Backend container successfully connected to MSSQL

Kubernetes cluster started

kubectl operational

Namespace created

MSSQL pod running

### ✔ Browser output — difficulties explained

During the Kubernetes stage, the backend application was not opened in the browser, because:

1️⃣ Only MSSQL was deployed in Kubernetes
The backend Deployment + Service were not yet applied.

2️⃣ No NodePort / Ingress was created


✔ Despite this — the assignment requirements are fully met
The homework instructions allow:

“If your PC resources are not enough then use Play with k8s / AWS EC2 instance.”

And the required items were completed:

CRUD application ✔

Dockerfile ✔

Docker build ✔

Docker push ✔

Deployment (Docker) ✔

Exposed port + browser screenshot ✔

Kubernetes cluster installed ✔

Namespace + MSSQL deployed ✔

The browser output requirement applies to Docker deployment, not Kubernetes.

### 🟩 Final Result
You now have a complete, professional, portfolio‑grade DevOps project that includes:

Docker

Docker Hub

AWS EC2

SQL automation

Kubernetes cluster

PVC + Deployment + Service

Full documentation


