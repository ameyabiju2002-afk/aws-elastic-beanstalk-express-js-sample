
pipeline {
  agent {
    docker {
      image 'node:16'
      args '-u 0:0'
    }
  }

  environment {
    IMAGE_REPO = '22063713/express-sample'
    IMAGE_TAG  = "build-${env.BUILD_NUMBER}"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      steps {
        sh 'npm install --save'
      }
    }


    stage('Test') {
      steps {
        sh 'npm test'
      }
    }

    
    stage('Build Docker image') {
      steps {
        script {
          def app = docker.build("${IMAGE_REPO}:${IMAGE_TAG}")
          sh "docker tag ${IMAGE_REPO}:${IMAGE_TAG} ${IMAGE_REPO}:latest"
        }
      }
    }

    stage('Push Docker image') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
            sh "docker push ${IMAGE_REPO}:${IMAGE_TAG}"
            sh "docker push ${IMAGE_REPO}:latest"
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'npm-debug.log', allowEmptyArchive: true
    }
  }
}
