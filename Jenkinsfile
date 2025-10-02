pipeline {
    agent any

    environment {
        GCP_PROJECT = 'jenkins-terraform-demo-472920'  // Cambia por tu proyecto
        IMAGE_NAME = 'fastapi-demo'                   // Nombre de la imagen Docker
        REGION = 'us-central1'                        // Región de Cloud Run
        REPO_URL = 'https://github.com/ScarletSC01/fastapi-demo.git'
        GITHUB_CREDENTIALS = 'github-token'          // Credenciales en Jenkins
        SONARQUBE_SERVER = 'SonarQube'               // Nombre del servidor SonarQube en Jenkins
    }

    stages {

        stage('Clonar repo') {
            steps {
                git(
                    url: "${REPO_URL}",
                    credentialsId: "${GITHUB_CREDENTIALS}"
                )
            }
        }

        stage('Instalar dependencias') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Ejecutar tests') {
            steps {
                sh 'pytest'
            }
        }

        stage('Analizar con SonarQube') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh 'sonar-scanner -Dsonar.projectKey=fastapi-demo -Dsonar.sources=.'
                }
            }
        }

        stage('Construir imagen Docker') {
            steps {
                sh """
                    docker build -t ${REGION}-docker.pkg.dev/${GCP_PROJECT}/fastapi-repo/${IMAGE_NAME}:latest .
                """
            }
        }

        stage('Subir imagen a Artifact Registry') {
            steps {
                sh """
                    gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
                    docker push ${REGION}-docker.pkg.dev/${GCP_PROJECT}/fastapi-repo/${IMAGE_NAME}:latest
                """
            }
        }

        stage('Desplegar en Cloud Run') {
            steps {
                sh """
                    gcloud run deploy ${IMAGE_NAME} \
                        --image ${REGION}-docker.pkg.dev/${GCP_PROJECT}/fastapi-repo/${IMAGE_NAME}:latest \
                        --region ${REGION} \
                        --platform managed \
                        --allow-unauthenticated
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline finalizado correctamente ✅'
        }
        failure {
            echo 'Pipeline falló ❌'
        }
    }
}
