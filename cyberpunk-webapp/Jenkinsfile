pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'dev',
                    url: 'https://github.com/Stanley29/cyberpunk-webapp.git'
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Deploy to WildFly') {
            steps {
                sh '''
                /opt/wildfly-cli/bin/jboss-cli.sh \
                  --connect \
                  --controller=13.48.29.172:9990 \
                  --user=jenkins \
                  --password=jenkins \
                  --command="/deployment=cyberpunk-webapp.war:remove" || true

                /opt/wildfly-cli/bin/jboss-cli.sh \
                  --connect \
                  --controller=13.48.29.172:9990 \
                  --user=jenkins \
                  --password=jenkins \
                  --command="deploy target/cyberpunk-webapp.war --force"
                '''
            }
        }
    }
}
