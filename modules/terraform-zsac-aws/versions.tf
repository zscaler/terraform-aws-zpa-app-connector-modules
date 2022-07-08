terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version  = "~> 4.2.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
  required_version = ">= 0.13"
}
