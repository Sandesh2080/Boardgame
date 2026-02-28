pipeline {
    agent { label 'podman' }

    tools {
        maven 'M3'
    }

    environment {
        AWS_ACCOUNT_ID   = "${env.AWS_ACCOUNT_ID}"    // configure in job or via parameters
        AWS_REGION       = "${env.AWS_REGION ?: 'us-east-1'}"
        ECR_REPO_PREFIX  = "${env.ECR_REPO_PREFIX ?: 'myorg'}"

        // A comma‑separated list of module names matching subdirs
        SERVICES         = "api-gateway,offer-service,product-service,service-registry"
    }
    
    stages {   
        stage('Compile') {
            steps {
            sh 'mvn compile'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn package'
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
                            | docker login \
                                --username AWS \
                                --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                }
            }
        }
    }
}
