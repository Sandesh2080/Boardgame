pipeline {
    agent { label 'podman' }

    environment {
        AWS_ACCOUNT_ID  = "${env.AWS_ACCOUNT_ID}"
        AWS_REGION      = "${env.AWS_REGION ?: 'us-east-1'}"
        IMAGE_NAME      = "Board-game"
        ECR_REPO        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
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
                    podman build \
                      -t ${IMAGE_NAME}:latest \
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS_CREDENTIALS'
                ]]) {
                    sh '''
                        aws --region ${AWS_REGION} ecr get-login-password \
                        | podman login \
                            --username AWS \
                            --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh '''
                    podman tag ${IMAGE_NAME}:latest ${ECR_REPO}:latest
                    podman push ${ECR_REPO}:latest
                '''
            }
        }
    }
}
