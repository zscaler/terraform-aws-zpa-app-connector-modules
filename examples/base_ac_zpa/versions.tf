terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }
    zpa = {
      source  = "zscaler/zpa"
      version = "~> 2.3.0"
    }
  }

  required_version = ">= 0.13.7, < 2.0.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "zpa" {
  zpa_client_id     = var.zpa_client_id
  zpa_client_secret = var.zpa_client_secret
  zpa_customer_id   = var.zpa_customer_id
}