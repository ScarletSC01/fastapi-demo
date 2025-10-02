pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://localhost:9000' 
        SONAR_TOKEN = 'sqa_fba5007ddebba30e5fb386b38f7b210320644679'
        PROJECT_ID = '<tu-proyecto-gcp>'
    }

    stages {
        stage('Clonar repo') {
            steps {
                git branch: 'main', url: 'https://github.com/ScarletSC01/fastapi-demo.git' 
                credentialsId: 'github-token'}
        }

        stage('Instalar dependencias') {
            steps {
                sh 'python3 -m venv venv'
                sh '. venv/bin/activate && pip install -r requirements.txt'
            }
        }

        stage('Ejecutar tests') {
            steps {
                sh '. venv/bin/activate && pip install pytest coverage && coverage run -m pytest && coverage xml'
            }
        }

        stage('Analizar con SonarQube') {
            steps {
                sh """
                docker run --rm --network=host \\
                    -e SONAR_HOST_URL=$SONAR_HOST_URL \\
                    -e SONAR_TOKEN=$SONAR_TOKEN \\
                    -v \$(pwd):/usr/src sonarsource/sonar-scanner-cli
                """
            }
        }

        stage('Construir imagen Docker') {
            steps {
                sh 'docker build -t gcr.io/$PROJECT_ID/fastapi-demo:latest .'
            }
        }

        stage('Subir imagen a Artifact Registry') {
            steps {
                sh 'docker push gcr.io/$PROJECT_ID/fastapi-demo:latest'
            }
        }

        stage('Desplegar en Cloud Run') {
            steps {
                sh 'gcloud run deploy fastapi-demo --image gcr.io/$PROJECT_ID/fastapi-demo:latest --region us-central1 --platform managed --allow-unauthenticated'
            }
        }
    }
}
