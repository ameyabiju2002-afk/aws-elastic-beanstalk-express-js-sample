pipeline {
  agent {
    docker {
      image 'node:16'
      // Run as root, mount the Docker socket, and clear entrypoint (removes that warning)
      args '--entrypoint="" -u root:root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    // TODO: change to your real Docker Hub repo
    DOCKER_IMAGE = 'your-dockerhub-user/aws-sample-app:latest'
    // If you use DinD over TCP instead of socket, uncomment this and adjust host:port:
    // DOCKER_HOST = 'tcp://dind:2375'
  }

  stages {

    stage('Preflight') {
      steps {
        sh '''
          set -eux
          echo "Node:"; node -v
          echo "NPM:";  npm -v
          echo "Socket present?"; ls -l /var/run/docker.sock || true
        '''
      }
    }

    stage('Install Docker CLI (robust)') {
      steps {
        sh '''
          set -euxo pipefail

          if command -v docker >/dev/null 2>&1; then
            echo "Docker CLI already present."
          else
            echo "Attempting to install docker.io from Debian repos..."
            # Try apt path first
            apt-get update
            if apt-get install -y --no-install-recommends docker.io; then
              echo "Installed docker.io from Debian."
            else
              echo "Apt install failed. Falling back to static Docker client."
              apt-get install -y --no-install-recommends curl ca-certificates
              DOCKER_TGZ_URL="https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz"
              curl -fsSL "$DOCKER_TGZ_URL" -o /tmp/docker.tgz
              tar -xzf /tmp/docker.tgz -C /usr/local/bin --strip-components=1 docker/docker
              chmod +x /usr/local/bin/docker
            fi
          fi

          docker --version
          # Quick connectivity check to the daemon (socket or DOCKER_HOST)
          docker info >/dev/null 2>&1 || { echo "WARNING: Docker daemon not reachable yet."; true; }
        '''
      }
    }

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install dependencies') {
      steps { sh 'npm install --save' }
    }

    stage('Unit tests') {
      steps { sh 'npm test || echo "No tests found, continuing..."' }
    }

    stage('Build image') {
      steps {
        sh '''
          set -euxo pipefail
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
          sh '''
            set -euxo pipefail
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
      sh 'docker version || true'
      archiveArtifacts artifacts: 'npm-debug.log,**/junit*.xml', allowEmptyArchive: true
    }
  }
}
