#Define terraform cloud workspace and organization
terraform {
  backend "remote" {
    organization = "jensen"

    workspaces {
      name = "mjensen0-quest"
    }
  }
}

#Set AWS region
provider "aws" {
  region = "us-east-2"
}

#Get default vpc
data "aws_vpc" "default" {
  default = true
}

#Get subnet IDs for region
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  } 
}


