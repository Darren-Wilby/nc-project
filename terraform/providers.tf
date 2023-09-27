terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.1"
    }
  }
  required_version = ">= 1.3.7"
}

provider "aws" {
  region = "eu-west-2"
}