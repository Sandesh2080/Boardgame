pipeline {
    agent { lable 'podman' }

    environment {
        AWS_ACCOUNT_ID = "${env.AWS_ACCOUNT_ID}"
        AWS_REGION     = "${env.AWS_REGION ?: 'us-east-1'}"
        IMAGE_NAME     = "board-game"
        ECR_REPO       = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
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
                    podman build -t ${IMAGE_NAME} .
                '''
            }
        }

        stage('Build & Push to ECR') {
            steps {
                script {
                    withAWS(credentials: 'AWS_CREDENTIALS', region: "${AWS_REGION}") {
                        sh '''
                            set -euxo pipefail

                            echo "===== AWS CLI Version ====="
                            aws --version

                            echo "===== Logging into ECR ====="
                            aws ecr get-login-password \
                                | podman login \
                                    --username AWS \
                                    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                            echo "===== Tagging Image ====="
                            podman tag ${IMAGE_NAME}:latest \
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
