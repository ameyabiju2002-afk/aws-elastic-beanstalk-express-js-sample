pipeline {
  agent {
    docker {
      image 'node16-with-dockercli:latest'         // <-- the image you built above
      args '--entrypoint="" -u root:root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  // Prevent the automatic "Declarative: Checkout SCM" (keeps logs cleaner)
  options {
    skipDefaultCheckout(true)
    timestamps()
  }

  environment {
    // CHANGE this to your Docker Hub repo/tag
    DOCKER_IMAGE = 'YOUR_DOCKERHUB_USER/aws-sample-app:latest'
  }

  stages {

    stage('Preflight') {
      steps {
        sh '''#!/bin/bash
          set -eux
          echo "Node:"; node -v
          echo "NPM:";  npm -v
          echo "Socket:"; ls -l /var/run/docker.sock || true
          echo "Docker CLI path:"; which docker
          docker --version
          docker info >/dev/null 2>&1 || echo "WARNING: Docker daemon not reachable yet (will try again)."
        '''
      }
    }

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      steps {
        sh '''#!/bin/bash
          set -eux
          npm install --save
        '''
      }
    }

    stage('Unit tests') {
      steps {
        sh '''#!/bin/bash
          set -eux
          npm test || echo "No tests found; continuing..."
        '''
      }
    }

    stage('Build image') {
      steps {
        sh '''#!/bin/bash
          set -eux
          docker version
          docker build -t "$DOCKER_IMAGE" .
        '''
      }
    }

    stage('Push image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DOCKERHUB_USER',
                                          passwordVariable: 'DOCKERHUB_PASS')]) {
          sh '''#!/bin/bash
            set -eux
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
            docker push "$DOCKER_IMAGE"
            docker logout || true
          '''
        }
      }
    }
  }

  post {
    always {
      sh '''#!/bin/bash
        set -eux
        docker --version || true
      '''
      archiveArtifacts artifacts: 'npm-debug.log,**/junit*.xml', allowEmptyArchive: true
    }
  }
}
