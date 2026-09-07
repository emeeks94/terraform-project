terraform {
  backend "s3" {
    bucket       = "emeka-freshcart-terraform-state-699588737174"
    key          = "freshcart/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }

  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
