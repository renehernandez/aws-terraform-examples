terraform {
  backend "s3" {
    bucket = "terraform-state-storage"
    key    = "terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    profile = "terraform"
  }
}