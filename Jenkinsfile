pipeline {
    agent {
        label 'linux-amd64'
    }
    options {
        buildDiscarder(logRotator(daysToKeepStr: '30'))
    }
    triggers { cron(env.BRANCH_NAME ==~ /^main$/ ? 'H H(0-6) 1 * *' : '') }
    environment {
        BUILDKIT_PROGRESS = 'plain'
    }
    stages {
        stage('Setup') {
            steps {
                script {
                   env.CONTEXT = sh(script: 'docker buildx create', returnStdout: true).trim()
                }
            }
        }
        stage('Build') {
            steps {
                sh 'docker buildx bake --builder "${CONTEXT}"'
            }
        }
        stage('Publish') {
            environment {
                DOCKER_REGISTRY_CREDS = credentials('docker-registry-credentials')
                DOCKER_REGISTRY = 'quay.io'
            }
            when {
                branch 'main'
            }
            steps {
                sh 'echo "$DOCKER_REGISTRY_CREDS_PSW" | docker login --username "$DOCKER_REGISTRY_CREDS_USR" --password-stdin "$DOCKER_REGISTRY"'
                sh 'docker buildx bake --builder "${CONTEXT}" --push'
            }
            post {
                always {
                    sh 'docker logout "$DOCKER_REGISTRY"'
                }
            }
        }
    }
    post {
        always {
            sh 'docker buildx rm "${CONTEXT}"'
            cleanWs()
        }
    }
}
