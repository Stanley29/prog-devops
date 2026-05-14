
# 🌍 Geography Application — Docker Deployment on AWS EC2

![Docker](https://img.shields.io/badge/Docker-Containerization-blue)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-green)
![Node.js](https://img.shields.io/badge/Node.js-Backend-brightgreen)
![AWS](https://img.shields.io/badge/AWS-EC2-yellow)
![Linux](https://img.shields.io/badge/Linux-Ubuntu%2022.04-lightgrey)
![Status](https://img.shields.io/badge/Status-Completed-success)


---

## 📘 Project Overview

This project deploys a complete backend stack on AWS EC2 using Docker:

-MongoDB container with seeded data

-Node.js API server container

-API endpoint /questions returning 15 geography questions

-Docker Hub publishing of both images

-Full troubleshooting and stabilization workflow

-Complete documentation with screenshots


This project demonstrates practical DevOps skills:

-Docker image creation

-Container orchestration

-Linux administration

-Debugging and troubleshooting

-AWS EC2 provisioning

-API validation

-Docker Hub publishing

---


## 📁 Project Structure

``` text
geography-application/
│
├── 01_DB/
│   ├── Dockerfile
│   ├── seed-data.js
│   ├── setup-db.sh
│
├── 02_Server/
│   ├── Dockerfile
│   ├── wait-mongo.sh
│   ├── server.js
│
├── images/
│   ├── 01_fork_repository.png
│   ├── 02_ec2_instance_running.png
│   ├── 03_ssh_connection.png
│   ├── 04_docker_installed.png
│   ├── 05_git_clone.png
│   ├── 06_build_db_image.png
│   ├── 06_build_db_image1.png
│   ├── 07_build_server_image.png
│   ├── 08_build_server_image.png
│   ├── 09_api_questions_output.png
│   ├── 10_dockerhub_push_db.png
│   ├── 12_dockerhub_repository.png
│
└── README.md
``` 

---

## 🧩 Step-by-Step Deployment


### Step 1 — Fork the repository 
 
Commands: (no terminal commands, done in browser)

![01_fork_repository.png](images/01_fork_repository.png)  


### Step 2 — Create EC2 instance  

Commands: (none — done in AWS Console) 

![02_ec2_instance_running.png](images/02_ec2_instance_running.png) 


### Step 3 — Connect to EC2 via SSH 
 
Command:

``` bash
ssh -i "HrSolution_Key_Pair.pem" ubuntu@<EC2_PUBLIC_IP>
``` 

![03_ssh_connection.png](images/03_ssh_connection.png)


### Step 4 — Install Docker on EC2  

Commands:

``` bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
``` 

![04_docker_installed.png](images/04_docker_installed.png)


### Step 5 — Clone the repository on EC2

Commands:

``` bash
git clone https://github.com/Stanley29/geography-application.git
ls -l
``` 

![05_git_clone.png](images/05_git_clone.png)


### Step 6 — Build MongoDB Docker image

Commands:

``` bash
cd geography-application/01_DB
docker build -t geography-db .
docker run -d --name geography-db -p 27017:27017 geography-db
docker logs geography-db
``` 

![06_build_db_image.png](images/06_build_db_image.png)
 


### Step 7 — Build MongoDB Docker image (Problems & Fixes)



#### Problem 1 — MongoDB ignored the seed file

Symptom:  
Container logs showed:

``` Code
ignoring /docker-entrypoint-initdb.d/seed-data.json
``` 

Cause:  
MongoDB executes only .js and .sh files during initialization.
.json files are always ignored.

Fix:  
Rename the file to .js.

Commands:

``` bash
mv seed-data.json seed-data.js
``` 


#### Problem 2 — MongoDB could not find the seed script (ENOENT)

Symptom:

``` Code
Error: ENOENT: no such file or directory, open '/docker-entrypoint-initdb.d/seed-data.js'
``` 

Cause:  
The Dockerfile did not copy the seed script into the correct directory inside the image.

Fix:  
Update Dockerfile to copy both scripts into /docker-entrypoint-initdb.d/.

Commands:

``` bash
cat > Dockerfile << 'EOF'
``` 

FROM mongo:7

``` 
COPY setup-db.sh /docker-entrypoint-initdb.d/
COPY seed-data.js /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/setup-db.sh
EXPOSE 27017
EOF
``` 

#### Problem 3 — Seed script failed to execute (auth expects user document)

Symptom:

``` Code
MongoshInvalidInputError: auth expects user document...
``` 

Cause:  
The seed file contained pure JSON instead of JavaScript.
MongoDB cannot execute JSON as a script.

Fix:  
Rewrite the seed file in valid JavaScript format.

Commands:

``` bash
cat > seed-data.js << 'EOF'
db = db.getSiblingDB("test");

db.questions.insertMany([
  { question: "Q1", answers: ["A","B"], answer: 0, weight: 1 },
  { question: "Q2", answers: ["A","B"], answer: 1, weight: 1 }
]);
EOF
``` 


#### Problem 4 — setup-db.sh did not run during initialization

Symptom:  
The script existed but was not executed by MongoDB.

Cause:  
The script did not have executable permissions.

Fix:  
Add chmod in Dockerfile.

Commands:

``` bash
RUN chmod +x /docker-entrypoint-initdb.d/setup-db.sh
``` 


#### Problem 5 — Duplicate documents inserted into MongoDB

Symptom:  
db.questions.find() returned duplicated entries.

Cause:  
MongoDB stores data in a persistent Docker volume.
Each time the container was recreated without removing the volume, the seed script ran again.

Fix:  
Remove the container and prune volumes before rebuilding.

Commands:

``` bash
docker rm -f geography-db
docker volume prune -f
docker run -d --name geography-db -p 27017:27017 geography-db
``` 

![06_build_db_image1.png](images/06_build_db_image1.png)


### Step 8 — Build Docker image for Server
Commands:

``` bash
cd geography-application/02_Server
cp Dockerfile.single Dockerfile
# Fix Dockerfile to correctly include wait-mongo.sh
docker build -t geography-server .
docker run -d --name geography-server --link geography-db -p 4000:4000 geography-server
docker logs geography-server
``` 

Description:  
During the server image build, the process failed because the Dockerfile attempted to run a command on wait-mongo.sh, but the script was not copied into the container.
The Dockerfile was updated to copy wait-mongo.sh into /usr/src/app and to run the sed command on the correct path.
After fixing the Dockerfile, the server image built successfully and the container was started with a link to the MongoDB container.
The logs were checked to confirm that the server started correctly and connected to the MongoDB instance.

![07_build_server_image.png](images/07_build_server_image.png)


### Step 9 — Troubleshooting and Stabilizing the Server Container

During this step, several critical issues prevented the Node.js server container from starting correctly. Each problem was identified, analyzed, and resolved systematically to ensure a stable and reproducible deployment.

#### 1. Missing Dockerfile and Incorrect Build Context

Problem:  
The 02_Server directory did not contain a default Dockerfile, only Dockerfile.single and Dockerfile.compose. Docker failed with:
“lstat Dockerfile: no such file or directory”

Solution:  
Dockerfile.single was copied and adapted into a proper Dockerfile with corrected paths and build instructions.

#### 2. Shell Incompatibility (bash → sh)

Problem:  
The base image node:20-alpine does not include Bash.
The startup script wait-mongo.sh used:

``` Code
#!/usr/bin/env bash
``` 

This caused the container to exit immediately with:
“env: can't execute 'bash': No such file or directory”

Solution:  
The script was updated to use the POSIX shell:

``` Code
#!/usr/bin/env sh
``` 

The Dockerfile CMD was also corrected to use sh instead of bash.

#### 3. Missing curl in Alpine

Problem:  
wait-mongo.sh uses curl to probe MongoDB readiness.
Alpine does not include curl by default, causing repeated errors:

“curl: not found”

Solution:  
curl was installed during the image build:

``` Code
RUN apk add --no-cache curl
``` 

#### 4. Disk Space Exhaustion on EC2 Instance

Problem:  
The EC2 instance ran out of disk space (100% /dev/root), causing Docker to fail during layer creation:

“no space left on device”

This prevented:

-npm installation

-curl installation

-layer creation

-image build

Solution:  
A full cleanup was performed:

``` Code
docker system prune -a --volumes -f
sudo rm -rf ~/.npm
sudo journalctl --vacuum-size=50M
``` 

This freed ~2.7 GB and restored normal Docker operation.

#### 5. MongoDB Authentication Failure

Problem:  
The server attempted to connect using:

``` Code
mongodb://admin:admin@geography-db:27017/geographydb?authSource=admin
``` 

But the MongoDB container had no admin user, resulting in:

“MongoServerError: Authentication failed (code 18)”

Solution:  
A proper admin user was created inside the MongoDB container:

``` javascript
use admin
db.createUser({
  user: "admin",
  pwd: "admin",
  roles: [ { role: "root", db: "admin" } ]
})
``` 

After this, the server successfully authenticated.

#### Final Result

After resolving all issues, the server container started successfully and connected to MongoDB:

``` Code
Connected to Mongodb
API listening on port 4000
Server started and wait requests
``` 

This completed Step 9 and stabilized the backend environment for further testing and frontend integration.

![08_build_server_image.png](images/08_build_server_image.png)


### Step 10 — API Verification (Questions Endpoint)

Commands:

``` bash
curl http://localhost:4000/questions
``` 

Description:
After inserting 15 question documents into the geographydb.questions collection, the API endpoint /questions was tested to verify that the server correctly retrieves data from MongoDB.
The endpoint returned a JSON array containing all 15 questions, confirming that:

MongoDB is running and accessible

The server is correctly connected to the geographydb database

The /questions route works as expected

The backend is fully operational

![09_api_questions_output.png](images/09_api_questions_output.png)


Expected output (example):

``` json
[
  { "_id": "...", "id": 1, "question": "What is the capital of France?", ... },
  { "_id": "...", "id": 2, "question": "What is the capital of Germany?", ... },
  ...
  { "_id": "...", "id": 15, "question": "What is the capital of Portugal?", ... }
]
``` 

Actual output:
The API returned all 15 inserted documents.

### Step 11 — Push Docker Images to Docker Hub

Commands:

``` bash
docker login
docker tag geography-db serhii128/geography-db
docker tag geography-server serhii128/geography-server
docker push serhii128/geography-db
docker push serhii128/geography-server
``` 

Description:
Both Docker images were successfully tagged with the Docker Hub namespace and pushed to the Docker Hub registry. This allows the images to be pulled and deployed on any machine without rebuilding them locally.

![10_dockerhub_push_db.png](images/10_dockerhub_push_db.png)




![12_dockerhub_repository.png](images/12_dockerhub_repository.png)

---

## 🎉 Final Result

The backend infrastructure is fully deployed and operational:

✔ MongoDB container running with seeded data

✔ Node.js API server connected and responding

✔ /questions endpoint returns 15 questions

✔ All Docker images published to Docker Hub

✔ EC2 instance hosts the full backend stack

✔ All issues resolved and documented