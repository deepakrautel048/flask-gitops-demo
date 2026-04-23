pipeline {
    agent any
    environment {
        DOCKER_HUB_USER = "deepakrautela048"
        APP_NAME = "flask-gitops-demo"
        // Use the github-token we created in Jenkins credentials
        GIT_CRED_ID = "github-token" 
    }
    stages {
        stage('Build & Push Docker') {
            steps {
                script {
                    // Build image with Jenkins Build Number as tag
                    sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:${BUILD_NUMBER} ."
                    
                    // Login and Push
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-login', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo \$PASS | docker login -u \$USER --password-stdin"
                        sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:${BUILD_NUMBER}"
                    }
                }
            }
        }
        stage('Update Git Manifest') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    script {
                        // 1. Change the tag in values.yaml
                        sh "sed -i 's/tag: .*/tag: ${BUILD_NUMBER}/g' charts/flask-app/values.yml"
                        
                        // 2. Push change back to GitHub
                        sh """
                            git config user.email "deepakrautel048@gmail.com"
                            git config user.name "deepakrautel048"
                            git add charts/flask-app/values.yml
                            git commit -m "Automated image update: version ${BUILD_NUMBER} [skip ci]"
                            git push https://${GITHUB_TOKEN}@github.com/deepakrautel048/flask-gitops-demo.git prod
                        """
                    }
                }
            }
        }
    }
}