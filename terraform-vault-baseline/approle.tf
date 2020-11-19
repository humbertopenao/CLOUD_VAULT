resource "vault_auth_backend" "approle" {
  type        = "approle"
  path        = var.approle_auth_path
  description = "Auth method for apps"
}

resource "vault_approle_auth_backend_role" "jenkins_role" {
  backend        = vault_auth_backend.approle.path
  role_name      = var.jenkins_role
  token_policies = ["jenkins"]
}

resource "vault_approle_auth_backend_role_secret_id" "jenkins" {
  backend      = vault_auth_backend.approle.path
  role_name    = vault_approle_auth_backend_role.jenkins_role.role_name
  wrapping_ttl = 3600
}

data "vault_approle_auth_backend_role_id" "jenkins" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.jenkins_role.role_name
}
