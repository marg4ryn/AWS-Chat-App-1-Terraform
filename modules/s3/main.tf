resource "aws_s3_bucket" "media_bucket" {
  bucket = "${var.bucket_name}"

  tags = {
    Name = "chatapp-s3"
  }
}
