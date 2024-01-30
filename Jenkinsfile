@Library('adda213-share-library')_
pipeline {
     environment {
       IMAGE_NAME = "static-website" 
       

     }
     agent none
     stages {
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
                  echo -e "aws_access_key_id = $aws_access_key_id" >> ~/.aws/credentials
                  echo -e "aws_secret_access_key = $aws_secret_access_key" >> ~/.aws/credentials
                  chmod 400 ~/.aws/credentials
                  echo "Generating aws private key"
                  cp $private_aws_key devops.pem
                  chmod 400 devops.pem
                  cd "./sources/terraform ressources/app"
                  mkdir -p ~/var/jenkins_home/workspace/ic-webapp/public_ip.txt
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

