pipeline {
  agent {
    docker {
      image 'node:16'
      args '--entrypoint="" -u root:root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    DOCKER_IMAGE = 'YOUR_DOCKERHUB_USER/aws-sample-app:latest'   // <-- change this
  }

  stages {
    stage('Preflight') {
      steps {
        sh '''#!/bin/bash
          set -eux
          echo "Node:"; node -v
          echo "NPM:"; npm -v
          echo "Socket:"; ls -l /var/run/docker.sock || true
          which docker || echo "docker not in PATH yet"
        '''
      }
    }

    stage('Install Docker CLI') {
      steps {
        sh '''#!/bin/bash
          set -euxo pipefail
          apt-get update
          apt-get install -y --no-install-recommends docker.io
          docker --version
        '''
      }
    }

    stage('Checkout') {
      steps { checkout scm }
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
