provider "aws" {
  region     = "sa-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source     = "./modules/vpc"
  name       = "Veloso Net - Test Environment"
  cidr_block = "10.16.0.0/16"
  public_subnets = [
    {
      cidr_block = "10.16.96.0/24",
      zone       = "sa-east-1a"
      name       = "Public Subnet 1A"
    },
    {
      cidr_block = "10.16.97.0/24",
      zone       = "sa-east-1b"
      name       = "Public Subnet 1B"
    },
    {
      cidr_block = "10.16.98.0/24",
      zone       = "sa-east-1c"
      name       = "Public Subnet 1C"
    }
  ]
}

module "kubernetes" {
  source = "./modules/kubernetes"

  master_name       = "Kubernetes Master"
  master_subnet     = module.vpc.public_subnets_ids[1]
  master_private_ip = "10.16.97.100"
  master_zone       = "sa-east-1b"
  ssh_key           = file(var.k8s_ssh_file)
  vpc_id            = module.vpc.vpc_id
}
