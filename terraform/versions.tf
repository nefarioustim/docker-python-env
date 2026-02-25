terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure once a remote backend bucket exists:
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "docker-python-env/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "your-terraform-state-lock"
  #   encrypt        = true
  # }
}
