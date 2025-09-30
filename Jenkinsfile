pipeline {
    agent {
        // Run all steps inside a Node.js 16 Docker container
        docker {
            image 'node:16'
            // Mount the host Docker socket so Jenkins can run Docker commands
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    stages {
        stage('Install dependencies') {
            steps {
                // Install project dependencies from package.json
                sh 'npm install --save'
            }
        }
        stage('Run tests') {
            steps {
                // Run the unit tests defined in package.json
                sh 'npm test'
            }
        }
        stage('Build Docker image') {
            steps {
                // Build Docker image with your Docker Hub username + repo
                sh 'docker build -t 22063713/assignment22063713:latest .'
            }
        }
        stage('Push Docker image') {
            steps {
                // Push image to Docker Hub using credentials stored in Jenkins
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh 'docker push 22063713/assignment22063713:latest'
                }
            }
        }
    }
}
