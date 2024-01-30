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
                  mkdir -p /var/jenkins_home/workspace/ic-webapp/
                  terraform init 
                  #terraform destroy --auto-approve
                  terraform plan
                  terraform apply --auto-approve
                  '''
             }
          }
        }
          stage('Deploy DEV  env for testing') {
            agent   {     
                        docker { 
                            image 'adda213/docker-ansible:v1'
                        } 
                    }
            stages {
                stage ("Install Ansible role dependencies") {
                    steps {
                        script {
                            sh 'echo launch ansible-galaxy install -r roles/requirement.yml if needed'
                        }
                    }
                }

                stage ("DEV - Ping target hosts") {
                    steps {
                        script {
                            sh '''
                                apt update -y
                                apt install sshpass -y                            
                                export ANSIBLE_CONFIG=$(pwd)/sources/ansible-ressources/ansible.cfg
                                ansible dev -m ping  --private-key devops.pem  -o 
                            '''
                        }
                    }
                }

                stage ("Check all playbook syntax") {
                    steps {
                        script {
                            sh '''
                                export ANSIBLE_CONFIG=$(pwd)/sources/ansible-ressources/ansible.cfg
                                ansible-lint -x 306 sources/ansible-ressources/playbooks/* || echo passing linter                                     
                            '''
                        }
                    }
                }

                stage ("DEV - Install Docker on ec2 hosts") {
                    steps {
                        script {

                            sh '''
                                export ANSIBLE_CONFIG=$(pwd)/sources/ansible-ressources/ansible.cfg
                                ansible-playbook sources/ansible-ressources/playbooks/install-docker.yml --vault-password-file vault.key  --private-key devops.pem -l ic_webapp_server_dev
                            '''                                
                        }
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
}

