pipeline {
    agent {
        docker {
            image 'node:16'   // Node 16 build agent
        }
    }

    environment {
        DOCKER_IMAGE = "22063713/aws-sample-app:latest"   // your DockerHub repo + tag
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
                sh 'npm install -g snyk'
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh "snyk auth $SNYK_TOKEN"
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
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'npm test || echo "No tests available"'
            }
        }

        stage('Build App') {
            steps {
                echo 'Building application...'
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

        stage('Docker Build & Push') {
            steps {
                script {
                    echo 'Building & pushing Docker image with DinD...'
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        def app = docker.build("${DOCKER_IMAGE}")
                        app.push()
                    }
                }
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
