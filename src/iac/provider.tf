terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  access_key = "<your_access_key_here>"
  secret_key = "<your_secret_key_here>"
}