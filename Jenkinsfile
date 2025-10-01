pipeline {
    agent {
        docker {
            image 'node:16'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    stages {
        stage('Install dependencies') {
            steps {
                sh 'npm install --save'
            }
        }

        stage('Run tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker image') {
            steps {
                sh 'docker build -t 22063713/express-sample:latest .'
            }
        }

        stage('Push Docker image') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-creds', url: '']) {
                    sh 'docker push 22063713/express-sample:latest'
                }
            }
        }

        stage('Security Scan') {
            steps {
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh 'npm install -g snyk'
                    sh 'snyk auth $SNYK_TOKEN'
                    // Fail the pipeline if HIGH or CRITICAL vulns are found
                    sh 'snyk test --severity-threshold=high'
                }
            }
        }
    }
}
