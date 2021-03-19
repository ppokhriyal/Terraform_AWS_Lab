//Create S3 Bucket
//Make it Private

#Configure AWS Provide
provider "aws" {
  region = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}

//Create Bucket
resource "aws_s3_bucket" "firstbucket" {
  bucket = "merarepo"
  acl = "private"

  tags = {
    Name = "My Repo"
    Environment = "Dev"
  }
}
