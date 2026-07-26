terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.37.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.9.0"
    }
  }
}
