pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:24.0.6-dind
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
'''
        }
    }
    environment {
        DOCKER_HUB_USER = "deepakrautela048"
        APP_NAME = "flask-gitops-demo"
        GIT_REPO = "github.com/deepakrautel048/flask-gitops-demo.git"
    }
    stages {
        stage('Build & Push Docker') {
            steps {
                container('docker') { // Use the docker container defined above
                    script {
                        sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:${BUILD_NUMBER} ."
                        
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-login', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                            sh "echo \$PASS | docker login -u \$USER --password-stdin"
                            sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:${BUILD_NUMBER}"
                        }
                    }
                }
            }
        }
        stage('Update Git Manifest') {
            steps {
                // We need git here, the docker image usually has it, 
                // but let's ensure we use the right container.
                container('docker') {
                    withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                        script {
                            sh "sed -i 's/tag: .*/tag: ${BUILD_NUMBER}/g' charts/flask-app/values.yml"
                            sh """
                                git config user.email "deepakrautel048@gmail.com"
                                git config user.name "deepakrautel048"
                                git add charts/flask-app/values.yml
                                git commit -m "image update: version ${BUILD_NUMBER} [skip ci]"
                                git push https://${GITHUB_TOKEN}@${GIT_REPO} prod
                            """
                        }
                    }
                }
            }
        }
    }
}