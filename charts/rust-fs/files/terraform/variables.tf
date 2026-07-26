variable "MINIO_ENDPOINT" {
  type = string
}
variable "MINIO_ENABLE_HTTPS" {
  type = bool
}
variable "MINIO_USER" {
  type = string
}
variable "MINIO_PASSWORD" {
  type      = string
  sensitive = true
}
variable "RUSTFS_INSTANCE" {
  type = string
}
variable "RESOURCES" {
  type = map(
    object({
      serviceName = string
      bucketName  = string
    })
  )
  description = "List of resources to create, each with a service name and bucket name."
}

variable "VAULT_ADDRESS" {
  type = string
}
variable "VAULT_APP_ROLE_LOGIN_PATH" {
  type = string
  default = "auth/approle/login"
}
variable "VAULT_APP_ROLE" {
  type = string
  sensitive = true
}
variable "VAULT_APP_ROLE_SECRET_ID" {
  type = string
  sensitive = true
}
variable "VAULT_KV_NAME" {
  type = string
}
variable "VAULT_KV_PREFIX" {
  type = string
  default = "rust-fs"
}