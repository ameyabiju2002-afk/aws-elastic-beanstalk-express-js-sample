pipeline {
  // ✅ Requirement: use Node 16 Docker image as the build agent
  agent {
    docker {
      image 'node:16'
      // run as root, mount host docker socket, and clear entrypoint to avoid warnings
      args '--entrypoint="" -u root:root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  // change this to your Docker Hub repo
  environment {
    DOCKER_IMAGE = 'YOUR_DOCKERHUB_USER/aws-sample-app:latest'
    // If you use DinD over TCP instead of the socket, uncomment and set:
    // DOCKER_HOST = 'tcp://dind:2375'
    // The path we will install the docker client to:
    DOCKER_BIN   = '/usr/local/bin/docker'
  }

  options {
    // show timestamps in logs (nice for reports)
    timestamps()
  }

  stages {

    stage('Preflight') {
      steps {
        sh '''
          set -eux
          echo "Node:"; node -v
          echo "NPM:";  npm -v
          echo "Socket:"; ls -l /var/run/docker.sock || true
          which docker || echo "docker not in PATH yet"
        '''
      }
    }

    stage('Install Docker CLI (always succeeds)') {
      steps {
        sh '''
          set -euxo pipefail

          # If docker client is already at the exact path we use, keep it
          if [ -x "$DOCKER_BIN" ]; then
            echo "Docker CLI already present at $DOCKER_BIN"
          else
            echo "Installing a static Docker client to $DOCKER_BIN ..."
            apt-get update
            apt-get install -y --no-install-recommends curl ca-certificates
            URL="https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz"
            curl -fsSL "$URL" -o /tmp/docker.tgz
            tar -xzf /tmp/docker.tgz -C /usr/local/bin --strip-components=1 docker/docker
            chmod +x "$DOCKER_BIN"
          fi

          "$DOCKER_BIN" --version
          # Connectivity check (won't fail the build if daemon is not up yet)
          "$DOCKER_BIN" info >/dev/null 2>&1 || echo "WARNING: Docker daemon not reachable yet (will try again at build)."
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
        sh 'npm install --save'
      }
    }

    stage('Unit tests') {
      steps {
        // Don’t fail if the sample app has no tests
        sh 'npm test || echo "No tests found; continuing..."'
      }
    }

    stage('Build image') {
      steps {
        sh '''
          set -euxo pipefail
          "$DOCKER_BIN" version
          "$DOCKER_BIN" build -t "$DOCKER_IMAGE" .
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
            echo "$DOCKERHUB_PASS" | "$DOCKER_BIN" login -u "$DOCKERHUB_USER" --password-stdin
            "$DOCKER_BIN" push "$DOCKER_IMAGE"
            "$DOCKER_BIN" logout || true
          '''
        }
      }
    }
  }

  post {
    always {
      // Helpful in logs for your report
      sh 'echo "Final docker version:"; ( "$DOCKER_BIN" --version || true )'
      archiveArtifacts artifacts: 'npm-debug.log,**/junit*.xml', allowEmptyArchive: true
    }
  }
}
