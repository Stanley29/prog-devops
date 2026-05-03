# Cyberpunk City – Simple Web Project

A minimal single‑page cyberpunk‑themed website created as a demo project for Jenkins CI/CD pipelines (Build + Deploy).  
The design uses neon colors, dark backgrounds, and futuristic styling inspired by cyberpunk aesthetics.

## Project Overview

- Single HTML page (`index.html`)
- Custom CSS styling (`styles.css`)
- Local images stored in the `images/` directory
- Suitable for deployment to any static web server (Nginx, Apache, WildFly static content, AWS EC2, etc.)
- Ideal for Jenkins pipelines that require:
  - Git checkout
  - Build (optional)
  - Deployment to a remote server

## Project Structure

```text
cyberpunk-site/
│── index.html
│── styles.css
└── images/
    ├── istockphoto-1893281874-612x612.jpg
    └── istockphoto-1405987908-2048x2048.jpg
```

## How to Run Locally

1)Clone the repository:

```bash
git clone <repository-url>
cd cyberpunk-site
```

2)Open the page in a browser:

-Double‑click index.html  
or

-Use a command:

```bash
xdg-open index.html
```
(Linux)

## Jenkins Pipeline Usage
This project is designed to be used in a Jenkins pipeline with the following stages:

1. Checkout
Pull the repository from GitHub.

2. Build
(Optional) Copy files into a build directory.

3. Deploy
Transfer the following to a target server (e.g., EC2 with WildFly or Nginx):

```text
/var/www/cyberpunk/
│── index.html
│── styles.css
└── images/
```

Deployment can be done using:

-scp

-SSH commands

-Jenkins SSH Agent plugin

-Custom deployment scripts


## License

This project is for demonstration purposes.
