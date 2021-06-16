#!groovy

pipeline {
    agent any

    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS')
    }

    environment {
        IMAGE_NAME_DESA = 'desa-demo2'
        IMAGE_NAME_DEV = 'dev-demo2'
        IMAGE_NAME = 'demo2'
        DOCKER_REG = 'jeatest00000002'
        DOCKER_CRED = 'docker_token'
        GOOGLE_CRED = credentials('gcp_sa')
    }

    stages {        
        stage('Build & push Docker image') {

            when {
                not { branch 'dev' }
                not { branch 'master' }
            }

            steps {
                script {
                    sh "s2i build https://github.com/jeademo/test fabric8/s2i-java:latest-java11 ${DOCKER_REG}/${IMAGE_NAME_DESA}:${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub_token') {
                        sh "docker push ${DOCKER_REG}/${IMAGE_NAME_DESA}:${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                    }
                }
            }
            post {
                always {
                    script {
                        sh "docker rmi -f ${DOCKER_REG}/${IMAGE_NAME_DESA}:${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
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

//def mvnw(String... args) {
//    sh "./mvnw ${args.join(' ')}"
//}