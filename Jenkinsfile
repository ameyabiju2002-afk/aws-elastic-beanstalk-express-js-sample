pipeline {
    agent {
        docker {
            image 'node:16-bullseye'  
            args '-u root:root --network jenkins_net -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_IMAGE = "22063713/aws-sample-app:latest"
    }

    stages {
        stage('Install Docker CLI') {
            steps {
                echo 'Installing Docker CLI inside Node.js 16 container...'
                sh 'apt-get update && apt-get install -y docker.io'
                sh 'docker --version'
                sh 'node -v'
                sh 'npm -v'
            }
        }
        // ... (keep your other stages exactly as you had them)
    }

    post {
        always { echo 'Pipeline execution completed' }
        success { echo 'Pipeline executed successfully' }
        failure { echo 'Pipeline failed' }
    }
}
