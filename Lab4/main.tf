//Create S3 Bucket
//Upload Single File
//Make it public

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

//Upload single file
resource "aws_s3_bucket_object" "fileobject" {
    bucket = aws_s3_bucket.firstbucket.id
    key = "Resume.docx"
    source = "/home/funix/Downloads/Resume.docx"
    etag = filemd5("/home/funix/Downloads/Resume.docx")
    acl = "public-read"
    
}
