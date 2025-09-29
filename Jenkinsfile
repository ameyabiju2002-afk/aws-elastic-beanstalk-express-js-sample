pipeline {
  agent { docker { image 'node:16' } }

  stages {
    stage('Install Dependencies') {
      steps {
        sh 'npm install --save'
      }
    }

    stage('Run Tests') {
      steps {
        sh 'npm test'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Use your Docker Hub repo name here
          def appImage = "22063713/express-sample:latest"
          sh "docker build -t ${appImage} ."
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',   // Jenkins credentials ID
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh 'docker push 22063713/express-sample:latest'
        }
      }
    }
  }
}
