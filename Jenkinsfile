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
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    sh '''
                        rm -rf fastapi-demo
                        git clone https://$GIT_USER:$GIT_TOKEN@github.com/ScarletSC01/fastapi-demo.git
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
                    export PATH=$HOME/.local/bin:$PATH
                    pip install --user -r requirements.txt
                '''
            }
        }

        stage('Ejecutar tests') {
            steps {
                sh '''
                    cd fastapi-demo
                    export PATH=$HOME/.local/bin:$PATH
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
                    script {
                        def scannerHome = tool name: 'SonarQube Scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                        sh """
                            docker run --rm --network=host \
                                -e SONAR_HOST_URL=$SONAR_HOST_URL \
                                -e SONAR_TOKEN=$SONAR_TOKEN \
                                -v \$(pwd):/usr/src sonarsource/sonar-scanner-cli
                        """
                    }
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
            echo 'Pipeline ejecutado exitosamente'
        }
        failure {
            echo 'Pipeline fallido'
        }
    }
}
