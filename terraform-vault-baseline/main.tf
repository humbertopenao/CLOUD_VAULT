provider vault {
  address         = data.terraform_remote_state.selected.outputs.vault_url
  token           = var.vault_token
  skip_tls_verify = true
}

data "terraform_remote_state" "selected" {
  backend = "s3"
  config = {
    bucket  = var.remote_state_bucket
    key     = var.remote_state_key
    region  = var.remote_state_region
  }
}

resource "vault_audit" "file" {
  type = "file"
  options = {
    file_path = data.terraform_remote_state.selected.outputs.vault_audit_filename
  }
}

resource "vault_mount" "kv_jenkins" {
  path        = var.jenkins_path
  type        = "kv"
  description = "Secrets for Jenkins"
}
