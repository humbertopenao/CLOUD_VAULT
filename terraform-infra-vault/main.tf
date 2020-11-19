provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  ssh_user     = module.ami.default_user
  samba_basedn = join(",", formatlist("DC=%s", split(".", var.samba_domain)))
  bastion_tpl_vars = {
    vault_ips    = module.ec2_vault.private_ip
    git_repo     = var.git_repo
    ssh_user     = local.ssh_user
    ssh_priv_key = tls_private_key.this.private_key_pem
    vault_vars = {
      server_cert      = tls_locally_signed_cert.vault.cert_pem
      server_key       = tls_private_key.vault.private_key_pem
      ca_cert          = tls_self_signed_cert.ca.cert_pem
      vault_version    = var.vault_version
      vault_audit_dir  = var.vault_audit_dir
      vault_audit_file = var.vault_audit_file
      aws_region       = var.aws_region
      aws_access_key   = aws_iam_access_key.iam_access_key.id
      aws_secret_key   = aws_iam_access_key.iam_access_key.secret
      aws_kms_key_id   = aws_kms_key.vault_key.key_id
    }
  }
  samba_tpl_vars = {
    samba_hostname            = var.samba_hostname
    samba_domain              = var.samba_domain
    samba_admin_pass          = random_password.samba_admin.result
    pub_sshkey                = tls_private_key.this.public_key_openssh
    ssh_user                  = local.ssh_user
    vault_ldap_user           = var.vault_ldap_user
    vault_ldap_password       = random_password.vault_ldap_user.result
    server_cert               = tls_locally_signed_cert.samba.cert_pem
    server_key                = tls_private_key.samba.private_key_pem
    ca_cert                   = tls_self_signed_cert.ca.cert_pem
    samba_vaultadmin_group    = var.samba_vaultadmin_group
    samba_vaultadmin_user     = var.samba_vaultadmin_user
    samba_vaultadmin_password = random_password.samba_vaultadmin_password.result
  }
}
