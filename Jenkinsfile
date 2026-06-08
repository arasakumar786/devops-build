pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerHub')
        IMAGE_NAME_DEV  = "arasakumar786/dev"
        IMAGE_NAME_PROD = "arasakumar786/prod"
        DEV_SERVER_IP = "65.2.137.121"
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
            when {
                expression {
                    return env.GIT_BRANCH == 'origin/dev' || env.GIT_BRANCH == 'dev'
                }
            }
            steps {
                sh '''
                    docker tag nginx-app:latest $IMAGE_NAME_DEV:latest
                    docker push $IMAGE_NAME_DEV:latest
                '''
            }
        }

        stage('Deploy to Dev') {
            when {
                expression {
                    return env.GIT_BRANCH == 'origin/dev' || env.GIT_BRANCH == 'dev'
                }
            }
            steps {
                sshagent(['ssh-server']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@${DEV_SERVER_IP} "mkdir -p ~/app"

                        scp -o StrictHostKeyChecking=no deploy.sh compose.yml ubuntu@${DEV_SERVER_IP}:~/app/

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
            when {
                expression {
                    return env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'main'
                }
            }
            steps {
                sh '''
                    docker tag nginx-app:latest $IMAGE_NAME_PROD:latest
                    docker push $IMAGE_NAME_PROD:latest
                '''
            }
        }

        stage('Get Prod Server IP') {
            when {
                expression {
                    return env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'main'
                }
            }
            steps {
		withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS KEY']]) {
                script {
                    env.SERVER_IP = sh(
                        script: '''
                            aws ec2 describe-instances \
                            --filters "Name=tag:Environment,Values=prod" \
                                      "Name=instance-state-name,Values=running" \
                            --query "Reservations[*].Instances[*].PublicIpAddress" \
                            --output text
                        ''',
                        returnStdout: true
                    ).trim()
                    echo "Server IP: ${env.SERVER_IP}"
                }
            }
        }
       }

        stage('Deploy to Prod') {
            when {
                expression {
                    return env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'main'
                }
            }
            steps {
                sshagent(['ssh-server']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${env.SERVER_IP} 'mkdir -p ~/tmp'

                        scp -o StrictHostKeyChecking=no \
                            deploy.sh docker-compose.yml \
                            ubuntu@${env.SERVER_IP}:~/tmp/

                        ssh -o StrictHostKeyChecking=no ubuntu@${env.SERVER_IP} '
                            cd ~/tmp
                            chmod +x deploy.sh
                            ./deploy.sh
                        '
                    """
                }
            }
        }
    }

    post {
        success {
    slackSend(
        channel: '#all-arasan',
        color: 'good',
        message: """
🚀 *Deployment Successful*

📦 Project   : ${env.JOB_NAME}
🔢 Build No  : #${env.BUILD_NUMBER}
🌿 Branch    : ${env.GIT_BRANCH}
👤 Triggered : ${env.BUILD_USER ?: 'Git Push'}

🐳 Docker Image:
- Dev  : ${IMAGE_NAME_DEV}:latest
- Prod : ${IMAGE_NAME_PROD}:latest

🌐 Server:
- Dev IP : ${DEV_SERVER_IP}

🔗 Jenkins: ${env.BUILD_URL}
"""
    )
}

        failure {
    slackSend(
        channel: '#all-arasan',
        color: 'danger',
        message: """
❌ *Deployment Failed*

📦 Project   : ${env.JOB_NAME}
🔢 Build No  : #${env.BUILD_NUMBER}
🌿 Branch    : ${env.GIT_BRANCH}

⚠️ Check logs:
👉 ${env.BUILD_URL}console

🐳 Possible Issues:
- Docker build failed
- Image push failed
- SSH connection issue
- Deploy script error

🛠️ Quick Action:
Re-run build or check Jenkins console output
"""
    )
}
    }
}
