@Library('adda213-share-library')_
pipeline {
     environment {
       IMAGE_NAME = "static-website" 
       IMAGE_TAG = "latest"
       STAGING = "adda213-staging"
       PRODUCTION = "adda213-production"
     }
     agent none
     stages {
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
                     curl http://192.168.56.3 | grep -i "dimension"
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
         stage('push image in production and deploy it') {
             when {
                         expression { GIT_BRANCH == 'origin/master' }
             }
             agent any
             environment {
                 HEROKU_API_KEY = credentials('heroku_api_key')
             }
             steps {   script {
                  sh '''
                     heroku container: login
                     heroku create $PRODUCTION || echo "project already exist"
                     heroku container:push -a $PRODUCTION web
                     heroku container:release -a $PRODUCTION web
                  '''  
                }
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
     
