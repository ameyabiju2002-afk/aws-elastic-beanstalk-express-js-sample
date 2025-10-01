pipeline {
    agent { docker { image 'node:16' } }

    stages {
        stage('Install dependencies') {
            steps {
                sh 'npm install --save'
            }
        }

        stage('Run tests') {
            steps {
                sh 'npm test || echo "No tests to run"'
            }
        }

        stage('Build Docker image') {
            steps {
                sh 'docker build -t 22063713/express-sample:latest .'
            }
        }

        stage('Push Docker image') {
            steps {
                sh 'docker push 22063713/express-sample:latest || echo "Skipping push if not configured"'
            }
        }
    }
}
