provider "minio" {
  minio_server   = var.MINIO_ENDPOINT
  minio_user     = var.MINIO_USER
  minio_password = var.MINIO_PASSWORD
  minio_ssl      = var.MINIO_ENABLE_HTTPS
}
provider "vault" {
  address = var.VAULT_ADDRESS
  auth_login {
    path = var.VAULT_APP_ROLE_LOGIN_PATH

    parameters = {
      role_id   = var.VAULT_APP_ROLE
      secret_id = var.VAULT_APP_ROLE_SECRET_ID
    }
  }
}
