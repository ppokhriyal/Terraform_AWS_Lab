//Create S3 Bucket
//Upload Single File
//Make it public
//Enable Versioning on Bucket

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

  versioning {
    enabled = true
  }
  tags = {
    Name = "My Repo"
    Environment = "Dev"
  }
}

//Upload single file
resource "aws_s3_bucket_object" "fileobject" {
    bucket = aws_s3_bucket.firstbucket.id
    key = "Resume.docx"
    source = "/home/funix/Desktop/test.txt"
    etag = filemd5("/home/funix/Desktop/test.txt")
    acl = "public-read"
}
