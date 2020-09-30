terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = "us-east-2"
  profile = "terraform"
}