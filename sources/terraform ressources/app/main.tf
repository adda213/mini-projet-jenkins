provider "aws" {
  region                   = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket                  = "s3-adda-213-bucket"
    key                     = "adda-dev.tfstate"
    region                  = "eu-west-3"
  }
}


# Création du sg
module "sg" {
  source = "../modules/sg"
}

# Création de l'EIP
module "eip" {
  source = "../modules/eip"
}

# Création de l'EC2 
module "ec2" {
  source        = "../modules/ec2"
  instance_type = "t2.micro"
  public_ip     = module.eip.output_eip
  sg_name       = module.sg.output_sg_name
  server_name   = "ic_webapp_server_dev"

}

#Creation des associations nécessaires
resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2.output_ec2_id
  allocation_id = module.eip.output_eip_id
}
