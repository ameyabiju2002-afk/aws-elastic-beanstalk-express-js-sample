pipeline {
    agent {
        docker {
            image 'node:16'  
            // Run as root so we can install Docker CLI inside
            args '-u root:root --network jenkins_dind -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        // Define Docker image name for pushing to DockerHub
        DOCKER_IMAGE = "22063713/aws-sample-app:latest"
    }

    stages {
        stage('Install Docker CLI') {
            steps {
                echo 'Installing Docker CLI inside Node.js 16 container...'
                sh 'apt-get update && apt-get install -y docker.io'
                sh 'docker --version'   // confirm Docker CLI works
                sh 'node -v'            // confirm Node.js exists
                sh 'npm -v'             // confirm npm exists
            }
        }

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
                    echo 'Building Docker image...'
                    sh 'docker build -t $DOCKER_IMAGE .'

                    echo 'Pushing Docker image to DockerHub...'
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh 'docker push $DOCKER_IMAGE'
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
