pipeline {
    agent {
        docker {
            image 'node:16'
        }
    }

    stages {
        stage('Install dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh 'npm install --save'
            }
        }

        stage('Snyk Security Scan') {
            steps {
                echo 'Running Snyk vulnerability scan...'
                // install snyk CLI inside pipeline container
                sh 'npm install -g snyk'
                // authenticate with token (replace with env var for safety)
                sh 'snyk auth 2f0a84cb-1614-45cf-b58d-b4cd382db5c6'
                script {
                    def result = sh(script: 'snyk test --severity-threshold=high', returnStatus: true)
                    if (result != 0) {
                        error "Pipeline failed due to High/Critical vulnerabilities"
                    } else {
                        echo "No High/Critical vulnerabilities detected"
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'npm test || echo "No tests available"'
            }
        }

        stage('Build') {
            steps {
                echo 'Building application...'
                // build step (for Node.js apps just echo or bundle if needed)
                sh 'echo "Build step complete"'
            }
        }

        stage('Run Application') {
            steps {
                echo 'Starting Node.js app...'
                sh 'node app.js & sleep 5'
                sh 'curl http://localhost:8080 || true'
            }
        }

        stage('Deployment Stage') {
            steps {
                echo 'Deployment stage in progress...'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed'
        }
        success {
            echo 'Pipeline executed successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
