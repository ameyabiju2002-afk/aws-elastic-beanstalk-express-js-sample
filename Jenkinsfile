pipeline {
  agent { docker { image 'node:16'; args '-u root' } }

  environment {
    APP_PORT = '8082'   // <— changed from 8080 to 8082
  }

  // … other stages …

  stage('Deploy & Smoke Test') {
    steps {
      sh '''
        apt-get update -y >/dev/null 2>&1
        apt-get install -y curl >/dev/null 2>&1

        node app.js & echo $! > .app_pid
        sleep 5
        curl -fsS http://localhost:${APP_PORT} > /dev/null
      '''
    }
    post {
      always {
        sh 'test -f .app_pid && kill -9 $(cat .app_pid) 2>/dev/null || true'
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'npm-debug.log', allowEmptyArchive: true
    }
  }
}
