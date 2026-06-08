pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerHub')
        IMAGE_NAME_DEV  = "arasakumar786/dev"
        IMAGE_NAME_PROD = "arasakumar786/prod"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh './build.sh'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                '''
            }
        }

        stage('Tag & Push (Dev)') {
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

        stage('Tag & Push (Prod)') {
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
✅ Build Successful

Job     : ${env.JOB_NAME}
Build   : #${env.BUILD_NUMBER}
Branch  : ${env.GIT_BRANCH}
URL     : ${env.BUILD_URL}
"""
            )
        }
        failure {
            slackSend(
                channel: '#all-arasan',
                color: 'danger',
                message: """
❌ Build Failed

Job     : ${env.JOB_NAME}
Build   : #${env.BUILD_NUMBER}
Branch  : ${env.GIT_BRANCH}
URL     : ${env.BUILD_URL}
"""
            )
        }
    }
}

