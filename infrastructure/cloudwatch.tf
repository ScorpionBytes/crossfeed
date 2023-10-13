resource "aws_s3_bucket" "cloudwatch_bucket" {
  bucket = var.cloudwatch_bucket_name
  tags = {
    project = var.project
    stage   = var.stage
  }
}

# TODO: update retention_in_days based on developing requirements
resource "aws_cloudwatch_log_group" "cloudwatch_bucket" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = 365
  kms_key_id        = aws_kms_key.key.arn
  tags = {
    project = var.project
    stage   = var.stage
  }
}

resource "aws_s3_bucket_policy" "cloudwatch_bucket" {
  bucket = aws_s3_bucket.cloudwatch_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AWSLogDeliveryGetBucketACL",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : aws_s3_bucket.cloudwatch_bucket.arn
      },
      {
        "Sid" : "AWSLogDeliveryWrite",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : [
          aws_s3_bucket.cloudwatch_bucket.arn,
          "${aws_s3_bucket.cloudwatch_bucket.arn}/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        "Sid" : "RequireSSLRequests",
        "Action" : "s3:*",
        "Effect" : "Deny",
        "Principal" : "*",
        "Resource" : [
          aws_s3_bucket.cloudwatch_bucket.arn,
          "${aws_s3_bucket.cloudwatch_bucket.arn}/*"
        ],
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_logging" "cloudwatch_bucket" {
  bucket        = aws_s3_bucket.cloudwatch_bucket.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "cloudwatch_bucket"
}