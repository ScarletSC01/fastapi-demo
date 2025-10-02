pipeline {
    agent any

    environment {
        PROJECT_ID = "jenkins-terraform-demo-472920"
        REGION     = "us-central1"
        SERVICE    = "fastapi-demo"
        IMAGE_NAME = "fastapi-demo"
        REPO       = "fastapi-repo"
    }

    stages {
        stage('Clonar repo con credencial') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    sh '''
                        rm -rf fastapi-demo
                        git clone https://$GITHUB_TOKEN@github.com/ScarletSC01/fastapi-demo.git
                        cd fastapi-demo
                        ls -la
                    '''
                }
            }
        }

        stage('Instalar dependencias') {
            steps {
                sh '''
                    cd fastapi-demo
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Ejecutar tests') {
            steps {
                sh '''
                    cd fastapi-demo
                    pytest --maxfail=1 --disable-warnings -q
                '''
            }
        }

        stage('Analizar con SonarQube') {
            environment {
                SONAR_HOST_URL     = "http://localhost:9000"
                SONAR_SCANNER_OPTS = "-Dsonar.projectKey=fastapi-demo"
            }
            steps {
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                        cd fastapi-demo
                        sonar-scanner \
                          -Dsonar.projectKey=fastapi-demo \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=$SONAR_HOST_URL \
                          -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Construir imagen Docker') {
            steps {
                sh '''
                    cd fastapi-demo
                    docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:$BUILD_NUMBER .
                '''
            }
        }

        stage('Subir imagen a Artifact Registry') {
            steps {
                sh '''
                    gcloud auth configure-docker $REGION-docker.pkg.dev -q
                    docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:$BUILD_NUMBER
                '''
            }
        }

        stage('Desplegar en Cloud Run') {
            steps {
                sh '''
                    gcloud run deploy $SERVICE \
                        --image=$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:$BUILD_NUMBER \
                        --platform=managed \
                        --region=$REGION \
                        --allow-unauthenticated
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline ejecutado exitosamente ✅'
        }
        failure {
            echo 'Pipeline falló ❌'
        }
    }
}

