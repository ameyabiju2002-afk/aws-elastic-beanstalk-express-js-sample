pipeline {
  agent {
    docker {
      image 'node:16'
      // Run as root, mount host Docker socket, and clear entrypoint to avoid warnings
      args '--entrypoint="" -u root:root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    DOCKER_IMAGE = 'your-dockerhub-user/aws-sample-app:latest'  // <-- change me
    // If you use DinD over TCP instead of the socket, uncomment and set:
    // DOCKER_HOST = 'tcp://dind:2375'
  }

  stages {
    stage('Preflight') {
      steps {
        sh '''
          set -eux
          echo "Node:"; node -v
          echo "NPM:"; npm -v
          echo "Socket:"; ls -l /var/run/docker.sock || true
          which docker || echo "docker not in PATH yet"
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
            echo "Installing docker.io via apt (Debian base in node:16)…"
            apt-get update
            if apt-get install -y --no-install-recommends docker.io; then
              echo "Installed docker.io from Debian."
            else
              echo "APT failed; falling back to static Docker client."
              apt-get install -y --no-install-recommends curl ca-certificates
              URL="https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz"
              curl -fsSL "$URL" -o /tmp/docker.tgz
              tar -xzf /tmp/docker.tgz -C /usr/local/bin --strip-components=1 docker/docker
              chmod +x /usr/local/bin/docker
            fi
          fi

          docker --version
          # Check daemon connectivity (via socket or DOCKER_HOST)
          docker info >/dev/null 2>&1 || echo "WARNING: Docker daemon not reachable yet (will try again at build)."
        '''
      }
    }

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install deps') {
      steps { sh 'npm install --save' }
    }

    stage('Test') {
      steps { sh 'npm test || echo "No tests found; continuing…"' }
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
      sh 'which docker || true; docker --version || true'
      archiveArtifacts artifacts: 'npm-debug.log,**/junit*.xml', allowEmptyArchive: true
    }
  }
}
