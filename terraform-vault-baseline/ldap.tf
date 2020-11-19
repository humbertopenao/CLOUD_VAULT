resource "vault_ldap_auth_backend" "ad" {
  path         = var.ldap_auth_path
  url          = data.terraform_remote_state.selected.outputs.samba_url
  binddn       = data.terraform_remote_state.selected.outputs.vault_ldap_userdn
  bindpass     = data.terraform_remote_state.selected.outputs.vault_ldap_password
  userdn       = data.terraform_remote_state.selected.outputs.samba_userdn
  userattr     = var.ldap_auth_userattr
  groupdn      = data.terraform_remote_state.selected.outputs.samba_groupdn
  groupattr    = var.ldap_auth_groupattr
  groupfilter  = var.ldap_auth_groupfilter
  insecure_tls = var.ldap_auth_insecure_tls
  starttls     = var.ldap_auth_starttls
  certificate  = data.terraform_remote_state.selected.outputs.samba_cert
}

resource "vault_ldap_auth_backend_group" "vault_admins" {
  groupname = data.terraform_remote_state.selected.outputs.vaultadmin_group
  policies  = ["vault_admin"]
  backend   = vault_ldap_auth_backend.ad.path
}
