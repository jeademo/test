#!groovy

pipeline {
    agent any

    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS')
    }

    environment {
        IMAGE_NAME_DESA = 'desa-demo1'
        IMAGE_NAME_DEV = 'dev-demo1'
        IMAGE_NAME = 'demo1'
        DOCKER_REG = 'jeatest00000002'
        DOCKER_CRED = 'docker_token'
        GOOGLE_CRED = credentials('gcp_sa')
    }

    stages {        
        stage('Compile') {
            steps {
                mvnw('compile')
            }
        }
        
        stage('Unit Tests') {
            steps {
                mvnw('test')
            }
        }

        stage("Code coverage") {
            steps {
                gradlew ('jacocoTestReport')
                    publishHTML (target: [
                        reportDir: 'build/reports/jacoco/test/html',
                        reportFiles: 'index.html',
                        reportName: 'JacocoReport'
                    ])
                gradlew ('jacocoTestCoverageVerification')
            }
        }
        
        stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv('sonar-jea') {
                    gradlew ('sonarqube')
                }
            }
        }

        stage('Build') {
            steps {
                gradlew('package')
            }
        }

        stage('Build & push Docker image') {

            when {
                not { branch 'dev' }
                not { branch 'master' }
            }

            steps {
                script {
                    def DockerImage = docker.build("${DOCKER_REG}/${IMAGE_NAME_DESA}")
                        docker.withRegistry('https://registry.hub.docker.com', 'dockerhub_token') {
                            DockerImage.push("${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
                        }
                    }
                }
            post {
                always {
                    script {
                        sh "docker rmi -f ${DOCKER_REG}/${IMAGE_NAME_DESA}"
                    }
                }
            }
        }

        stage('dev') {
            when {
                branch 'dev'
            }
            stages {
                stage('dev: Build & push Docker image') {
                    steps {
                        script {
                            def DockerImage = docker.build("${DOCKER_REG}/${IMAGE_NAME_DEV}")
                            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub_token') {
                                DockerImage.push("${env.BUILD_NUMBER}")
                                DockerImage.push("latest")
                            }
                        }
                    }
                    post {
                        always {
                            script {
                                sh "docker rmi -f ${DOCKER_REG}/${IMAGE_NAME_DEV}"
                            }
                        }
                    }
                }

                stage('dev: Deploy to GKE'){
                    steps {
                        script {
                            sh "./deploy-gke-dev/deploy.sh \"${env.BUILD_NUMBER}\""
                        }
                    }
                }
            }
        }

        stage('prod') {
            when {
                branch 'master'
            }
            stages {
                stage('prod: Build & push Docker image') {
                    steps {
                        script {
                            def DockerImage = docker.build("${DOCKER_REG}/${IMAGE_NAME}")
                            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub_token') {
                                DockerImage.push("${env.BUILD_NUMBER}")
                                DockerImage.push("latest")
                            }
                        }
                    }
                    post {
                        always {
                            script {
                                sh "docker rmi -f ${DOCKER_REG}/${IMAGE_NAME}"
                            }
                        }
                    }
                }

                stage('prod: Deploy to GKE'){
                    steps {
                        script {
                            sh "./deploy-gke/deploy.sh \"${env.BUILD_NUMBER}\""
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

def mvnw(String... args) {
    sh "./mvnw ${args.join(' ')}"
}

//