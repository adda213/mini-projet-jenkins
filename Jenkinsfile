@Library('adda213-share-library')_
pipeline {
     environment {
       IMAGE_NAME = "static-website" 
       IMAGE_TAG = "latest"
       STAGING = "adda213-staging"
       PRODUCTION = "adda213-production"
       APP_NAME = "adda-staticwebsite" 
       REVIEW_APP_NAME = "adda-${IMAGE_TAG}"
       IP_EAZY = "ip10-0-3-3-cjeaf37fep9gq55gr900"
       REPOSITORY_ADRESS = "direct.docker.labs.eazytraining.fr"
       API_PORT = "80"
       API_ENDPOINT = "${IP_EAZY}-${API_PORT}.${REPOSITORY_ADRESS}"
       INTERNAL_PORT = "80"
       TEST_PORT = "90"
       STG_EXTERNAL_PORT = "8080"
       EXTERNAL_PORT = "80"
       CONTAINER_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"

     }
     agent none
     stages {
         stage('Clean Container1') {
             agent any
             steps {
                script {
                  sh '''
                     if 
                      docker ps | grep -i "$IMAGE_NAME"
                     then 
                      docker stop $IMAGE_NAME
                      docker rm -f $IMAGE_NAME
                     fi
                  '''  
                }
             }
         }
         stage('Build image') {
             agent any
             steps {
                script {
                  sh 'docker build -t adda213/$IMAGE_NAME:$IMAGE_TAG .'  
                }
             }
         }
         stage('run container based on build image') {
             agent any
             steps {
                script {
                  sh '''
                     docker run --name $IMAGE_NAME -d -p 80:5000 -e PORT=5000 adda213/$IMAGE_NAME:$IMAGE_TAG
                     sleep 5
                  '''  
                }
             }
         }
         stage('Test image') {
             agent any
             steps {
                script {
                  sh '''
                     curl http://192.168.99.10 | grep -i "dimension"
                  '''  
                }
             }
         }
         
         stage('push image in dockerhub') {
             when {
                         expression { GIT_BRANCH == 'origin/master' }
             }
             agent any
             environment {
                 password_docker = credentials('password_docker')
             }
             steps {   script {
                  sh '''
                     docker login --username=adda213 --password=$password_docker
                     docker push adda213/$IMAGE_NAME:$IMAGE_TAG
                  '''  
                }
             }

         }
          stage('Clean Container') {
             agent any
             steps {
                script {
                  sh '''
                      docker stop $IMAGE_NAME
                      docker rm -f $IMAGE_NAME
               
                  '''  
                }
             }
         }
          stage('deploy image in prod') {
             when {
                         expression { GIT_BRANCH == 'origin/master' }
             }
             agent any
             steps {
          script {
            sh '''
                     docker run --name $IMAGE_NAME-prod -d -p 80:5000 -e PORT=5000 adda213/$IMAGE_NAME:$IMAGE_TAG
                     sleep 5
                  '''  
          }
       }
         }


     

     
 post {
       always {
           script { 
                slackNotifier currentBuild.result
           }
        }
 }
}
}




     

     
