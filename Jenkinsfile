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
                      docker stop $IMAGE_NAME-prod
                      docker rm -f $IMAGE_NAME-prod
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
          stage('Clean Container2') {
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
          stage ('Build EC2 on AWS with terraform') {
          agent { 
                    docker { 
                            image 'jenkins/jnlp-agent-terraform'  
                    } 
                }
          environment {
            AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
            AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
            PRIVATE_AWS_KEY = credentials('private_aws_key')
          }          
          steps {
             script {
               sh '''
                  echo "Generating aws credentials"
                  echo "Deleting older if exist"
                  rm -rf devops.pem ~/.aws 
                  mkdir -p ~/.aws
                  echo "[default]" > ~/.aws/credentials
                  echo -e "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> ~/.aws/credentials
                  echo -e "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> ~/.aws/credentials
                  chmod 400 ~/.aws/credentials
                  echo "Generating aws private key"
                  cp $private_aws_key devops.pem
                  chmod 400 devops.pem
                  cd "./sources/terraform ressources/app"
                  terraform init 
                  #terraform destroy --auto-approve
                  terraform plan
                  terraform apply --auto-approve
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

