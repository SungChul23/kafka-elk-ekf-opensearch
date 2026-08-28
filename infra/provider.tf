provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project  = var.project_name
      ManageBy = "Terraform"
      Purpose  = "로그 재너레이터"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}