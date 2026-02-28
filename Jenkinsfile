pipeline {
    agent { label 'podman' }

    environment {
        AWS_ACCOUNT_ID = "045973518289"
        AWS_CRED = "${env.AWS_CRED}"
        AWS_REGION     = "${env.AWS_REGION ?: 'us-east-1'}"
        IMAGE_NAME     = "dev/microsvc"
        ECR_REPO       = "045973518289.dkr.ecr.us-east-1.amazonaws.com/dev/microsvc"
    }

    stages {

        stage('Build Application') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                    podman build -t board-game .
                '''
            }
        }

        stage('Build & Push to ECR') {
            steps {
                script {
                    withAWS(credentials: 'AWS_CRED', region: "${AWS_REGION}") {
                        sh '''
                            #!/bin/bash
                            set -eux

                            echo "===== AWS CLI Version ====="
                            aws --version

                            echo "===== Logging into ECR ====="
                            aws ecr get-login-password \
                                | podman login \
                                    --username AWS \
                                    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                            echo "===== Tagging Image ====="
                            podman tag board-game:latest \
                                ${ECR_REPO}:latest

                            echo "===== Pushing Image ====="
                            podman push \
                                ${ECR_REPO}:latest

                            echo "===== DONE ====="
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Image pushed to ECR: ${ECR_REPO}:latest"
        }
    }
}
