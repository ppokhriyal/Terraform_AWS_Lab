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
    for_each = fileset("/home/funix/Downloads/","*")
    bucket = aws_s3_bucket.firstbucket.id
    key = each.value
    source = "/home/funix/Downloads/${each.value}"
    etag = filemd5("/home/funix/Downloads/${each.value}")
    acl = "public-read"
    
}
