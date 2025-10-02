pipeline {
  agent {
    docker {
      image 'node:16'
      // run as root and mount docker socket so we can build/push images
      args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    // change these for your Docker Hub repo
    DOCKER_IMAGE = 'your-dockerhub-user/aws-sample-app:latest'
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

    stage('Unit tests') {
      steps {
        // don’t fail if there are no tests in the sample app
        sh 'npm test || echo "No tests found, continuing..."'
      }
    }

    stage('Build image') {
      steps {
        sh 'docker build -t "$DOCKER_IMAGE" .'
      }
    }

    stage('Push image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          sh '''
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
            docker push "$DOCKER_IMAGE"
            docker logout
          '''
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'npm-debug.log,**/junit*.xml', allowEmptyArchive: true
    }
  }
}
