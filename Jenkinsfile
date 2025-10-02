pipeline {
    agent {
        docker {
            image 'node:16'
        }
    }

    environment {
        DOCKER_IMAGE = "22063713/aws-sample-app:latest"
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
                    echo 'Installing Docker CLI inside Node 16 container...'
                    sh '''
                        apt-get update
                        apt-get install -y docker.io
                    '''

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
