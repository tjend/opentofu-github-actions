# expose environment variable TF_VAR_STATE_ENCRYPTION_PASSPHRASE as var.STATE_ENCRYPTION_PASSPHRASE
variable "STATE_ENCRYPTION_PASSPHRASE" {}

terraform {
  encryption {
    key_provider "pbkdf2" "passphrase" {
      passphrase = var.STATE_ENCRYPTION_PASSPHRASE
    }
    method "aes_gcm" "method" {
      keys = key_provider.pbkdf2.passphrase
    }
    plan {
      enforced = true
      method   = method.aes_gcm.method
    }
    state {
      enforced = true
      method   = method.aes_gcm.method
    }
  }
}
