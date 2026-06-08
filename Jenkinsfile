pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerHub')
        IMAGE_NAME_DEV  = "arasakumar786/dev"
        IMAGE_NAME_PROD = "arasakumar786/prod"
        DEV_SERVER_IP = "13.234.239.120"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                    chmod +x build.sh
                    ./build.sh
                '''
            }
        }

        stage('Docker Login') {
            steps {
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                '''
            }
        }

        stage('Push Dev Image') {
            when { branch 'dev' }
            steps {
                sh '''
                    docker tag nginx-app:latest $IMAGE_NAME_DEV:latest
                    docker push $IMAGE_NAME_DEV:latest
                '''
            }
        }

        stage('Deploy to Dev') {
            when { branch 'dev' }
            steps {
                sshagent(['ssh-server']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@${DEV_SERVER_IP} "mkdir -p ~/app"

                        scp -o StrictHostKeyChecking=no deploy.sh docker-compose.yml ubuntu@${DEV_SERVER_IP}:~/app/

                        ssh -o StrictHostKeyChecking=no ubuntu@${DEV_SERVER_IP} "
                            cd ~/app &&
                            chmod +x deploy.sh &&
                            ./deploy.sh dev
                        "
                    '''
                }
            }
        }

        stage('Push Prod Image') {
            when { branch 'main' }
            steps {
                sh '''
                    docker tag nginx-app:latest $IMAGE_NAME_PROD:latest
                    docker push $IMAGE_NAME_PROD:latest
                '''
            }
        }
    }

    post {
        success {
            slackSend(
                channel: '#all-arasan',
                color: 'good',
                message: "✅ Build Success - ${env.BRANCH_NAME} - #${env.BUILD_NUMBER}"
            )
        }

        failure {
            slackSend(
                channel: '#all-arasan',
                color: 'danger',
                message: "❌ Build Failed - ${env.BRANCH_NAME} - #${env.BUILD_NUMBER}"
            )
        }
    }
}
