terraform {
  required_providers {
    zpa = {
      version = "4.3.81"
      source  = "zscaler.com/zpa/zpa"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}
