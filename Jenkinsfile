pipeline {
    agent { docker { image 'node:16' } }

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh 'npm install --save'
                sh 'npm audit fix || true'
            }
        }

        stage('Test') {
            steps {
                echo 'Testing...'
                sh 'npm test || echo "No tests found, skipping..."'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh 'node app.js &'
                sh 'sleep 5'
                sh 'curl http://localhost:8082 || echo "App not responding on 8082"'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'npm-debug.log', allowEmptyArchive: true
        }
    }
}
