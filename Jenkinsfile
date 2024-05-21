pipeline {
    agent none
    options {
        buildDiscarder(logRotator(daysToKeepStr: '30'))
    }
    triggers { cron(env.BRANCH_NAME ==~ /^main$/ ? 'H H(0-6) 1 * *' : '') }
    stages {
        stage('Matrix') {
            matrix {
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'linux-amd64', 'linux-arm64'
                    }
                }
                environment {
                    COMPOSE_DOCKER_CLI_BUILD = 1
                    DOCKER_BUILDKIT = 1
                    TAG_SUFFIX = "-${PLATFORM}"
                }
                stages {
                    stage('Build, Publish') {
                        agent { label "${PLATFORM}" }
                        stages {
                            stage('Build') {
                                steps {
                                    sh 'docker-compose build'
                                }
                            }
                            stage('Test') {
                                steps {
                                    sh 'docker-compose run test'
                                }
                            }
                            stage('Publish') {
                                environment {
                                    DOCKER_REGISTRY_CREDS = credentials('docker-registry-credentials')
                                    DOCKER_REGISTRY = 'quay.io'
                                    BUILD = 'chromium'
                                }
                                when {
                                    branch 'main'
                                }
                                steps {
                                    sh 'echo "$DOCKER_REGISTRY_CREDS_PSW" | docker login --username "$DOCKER_REGISTRY_CREDS_USR" --password-stdin "$DOCKER_REGISTRY"'
                                    sh 'docker-compose config --services | grep -E "${BUILD}" | xargs docker-compose push'
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
                                sh 'docker-compose down -v --rmi local'
                                cleanWs()
                            }
                        }
                    }
                }
            }
        }
        stage('Publish main image') {
            agent { label "linux-amd64" }
            environment {
                DOCKER_REGISTRY_CREDS = credentials('docker-registry-credentials')
                DOCKER_REGISTRY = 'quay.io'
            }
            when {
                branch 'main'
            }
            steps {
                sh './manifest-push.sh'
            }
            post {
                always {
                    sh 'docker logout "$DOCKER_REGISTRY"'
                    cleanWs()
                }
            }
        }
    }
}
