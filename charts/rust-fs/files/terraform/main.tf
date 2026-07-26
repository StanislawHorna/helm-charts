# Bucket
resource "minio_s3_bucket" "s3_bucket" {
  for_each = var.RESOURCES

  bucket = each.value.bucketName
}
# Unified User (Access Key & Secret Key Pair)
## Generate a unique suffix for the username (Access Key)
resource "random_string" "s3_username" {
  for_each = var.RESOURCES

  length  = 6
  special = false
  upper   = false
}

## Generate a secure, high-entropy Secret Key
resource "random_password" "s3_secret" {
  for_each = var.RESOURCES

  length           = 32
  special          = true
  override_special = "!-_="
}

resource "minio_iam_user" "s3_user" {
  for_each = var.RESOURCES

  name   = "${each.value.serviceName}-${random_string.s3_username[each.key].result}"
  secret = random_password.s3_secret[each.key].result
  tags = {
    service-name = each.value.serviceName
  }
}
# IAM Policy allowing ALL actions inside the target bucket
resource "minio_iam_policy" "s3_policy" {
  for_each = var.RESOURCES
  name     = "${each.value.serviceName}-bucket-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAllActionsInsideBucket"
        Effect    = "Allow"
        Action    = ["s3:*"]
        Condition = {}
        Resource = [
          "arn:aws:s3:::${minio_s3_bucket.s3_bucket[each.key].bucket}",
          "arn:aws:s3:::${minio_s3_bucket.s3_bucket[each.key].bucket}/*"
        ]
      }
    ]
  })
}
resource "minio_iam_user_policy_attachment" "s3_policy_attachment" {
  for_each = var.RESOURCES

  user_name   = minio_iam_user.s3_user[each.key].id
  policy_name = minio_iam_policy.s3_policy[each.key].name
}

resource "vault_generic_secret" "s3_bucket_credentials" {
  for_each = var.RESOURCES

  path = "${var.VAULT_KV_NAME}/${var.VAULT_KV_PREFIX}/${var.RUSTFS_INSTANCE}/${each.key}"

  data_json = jsonencode({
    endpoint   = var.RUSTFS_INSTANCE
    bucket     = minio_s3_bucket.s3_bucket[each.key].bucket
    access_key = minio_iam_user.s3_user[each.key].id
    secret_key = random_password.s3_secret[each.key].result
  })
}


