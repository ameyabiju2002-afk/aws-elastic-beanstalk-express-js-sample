pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/<your-username>/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Security Scan') {
            steps {
                // Run Snyk to scan for vulnerabilities
                sh 'snyk test'
            }
        }

        stage('Build Docker image') {
            steps {
                sh 'docker build -t my-app .'
            }
        }

        stage('Push Docker image') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_HUB_TOKEN')]) {
                    sh 'echo $DOCKER_HUB_TOKEN | docker login -u <your-username> --password-stdin'
                    sh 'docker push my-app'
                }
            }
        }
    }
}
