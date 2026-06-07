pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerHub')
        IMAGE_NAME_DEV = "arasakumar786/dev"
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
                branch 'dev'
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
                branch 'master'
            }
            steps {
                sh '''
                docker tag nginx-app:latest $IMAGE_NAME_PROD:latest
                docker push $IMAGE_NAME_PROD:latest
                '''
            }
        }

        stage('Deploy to Prod') {
            when {
                branch 'master'
            }
            steps {
                sh './deploy.sh'
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

Job: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
Branch: ${env.BRANCH_NAME}
URL: ${env.BUILD_URL}
"""
            )
        }

        failure {
            slackSend(
                channel: '#all-arasan',
                color: 'danger',
                message: """
❌ Build Failed

Job: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
Branch: ${env.BRANCH_NAME}
URL: ${env.BUILD_URL}
"""
            )
        }
    }
}
