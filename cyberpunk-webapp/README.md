# Cyberpunk WebApp – Java WAR Project

A minimal cyberpunk‑themed web application packaged as a Java WAR file for deployment on WildFly.

## Project Overview
- Single HTML page (`index.html`)
- Custom CSS styling (`styles.css`)
- Local images stored in `images/`
- Packaged as a `.war` using Maven
- Deployable to WildFly, JBoss EAP, or any Java EE server

## Project Structure


```cyberpunk-webapp/
│── pom.xml
│── src/main/webapp/
│   ├── index.html
│   ├── styles.css
│   ├── images/
│   └── WEB-INF/web.xml
```

## Build
```
mvn clean package
```

Produces:

```
target/cyberpunk-webapp.war
```

## Deploy
Use Jenkins pipeline or CLI:

```
jboss-cli.sh --connect --command="deploy target/cyberpunk-webapp.war --force"
```

## License
Demo project for CI/CD labs.

