terraform {
  required_version = "1.2.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
