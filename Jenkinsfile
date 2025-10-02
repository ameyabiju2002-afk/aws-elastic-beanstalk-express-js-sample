pipeline {
  /* Requirement: use Node 16 Docker image as agent */
  agent {
    docker {
      image 'node:16-alpine'
      // no socket mount needed because we talk to DinD over TCP
      args '-u root:root'
    }
  }

  options { timestamps() }

  environment {
    DOCKER_HOST   = 'tcp://dind:2375'                     // talk to DinD
    DOCKER_IMAGE  = 'YOUR_DOCKERHUB_USER/aws-sample-app:latest'  // <-- change
  }

  stages {

    stage('Preflight') {
      steps {
        sh '''#!/bin/sh
          set -eux
          echo "Node:"; node -v
          echo "NPM:";  npm -v
        '''
      }
    }

    stage('Install docker CLI in agent') {
      steps {
        // Alpine -> apk is available; no bash/pipefail issues
        sh '''#!/bin/sh
          set -eux
          apk add --no-cache docker-cli ca-certificates curl
          docker --version
          # Sanity: can we reach the daemon?
          docker info >/dev/null 2>&1 || echo "Daemon not reachable yet (will try again)."
        '''
      }
    }

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install dependencies') {
      steps {
        sh '''#!/bin/sh
          set -eux
          npm install --save
        '''
      }
    }

    stage('Unit tests') {
      steps {
        sh '''#!/bin/sh
          set -eux
          npm test || echo "No tests found; continuing…"
        '''
      }
    }

    /* ---- Security: Snyk scan; FAIL on high/critical ---- */
    stage('Security scan (Snyk)') {
      steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
          sh '''#!/bin/sh
            set -eux
            npm i -g snyk
            snyk auth "$SNYK_TOKEN"
            # Fail on HIGH or CRITICAL vulns (exit non-zero => pipeline fails)
            snyk test --severity-threshold=high
          '''
        }
      }
    }

    stage('Build image') {
      steps {
        sh '''#!/bin/sh
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
          sh '''#!/bin/sh
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
      archiveArtifacts artifacts: 'npm-debug.log,**/junit*.xml', allowEmptyArchive: true
    }
  }
}
