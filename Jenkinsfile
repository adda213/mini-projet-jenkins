@Library('adda213-share-library')_
pipeline {
     
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
                  echo -e "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> ~/.aws/credentials
                  echo -e "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> ~/.aws/credentials
                  chmod 400 ~/.aws/credentials
                  echo "Generating aws private key"
                  touch devops.pem
                  cp \$PRIVATE_AWS_KEY devops.pem
                  chmod 400 devops.pem
                  '''
             }
          }
        }
     }
}

     

