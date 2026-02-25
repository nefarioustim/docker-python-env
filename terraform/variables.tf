variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name, used as a prefix for resource names and tags"
  type        = string
  default     = "docker-python-env"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}
