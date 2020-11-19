output "vault_url" {
  value       = "https://${module.elb.this_lb_dns_name}:${var.vault_port}"
  description = "URL used to connect to Vault"
}

output "vault_ldap_userdn" {
  value       = "CN=${var.vault_ldap_user},CN=Users,${local.samba_basedn}"
  description = "DN used for binding to the Samba LDAP service"
}

output "vault_ldap_password" {
  value       = random_password.vault_ldap_user.result
  description = "Credentials of the vault user used to bind to Samba LDAP service"
}

output "vault_audit_filename" {
  value       = "${var.vault_audit_dir}/${var.vault_audit_file}"
  description = "Path to the Vault audit filename"
}

output "vaultadmin_user" {
  value       = var.samba_vaultadmin_user
  description = "LDAP user with admin privileges in Vault"
}

output "vaultadmin_group" {
  value       = var.samba_vaultadmin_group
  description = "LDAP group with admin privileges in Vault"
}

output "vaultadmin_password" {
  value       = random_password.samba_vaultadmin_password.result
  description = "Password of LDAP user with admin privileges in Vault"
}

output "samba_userdn" {
  value       = "CN=Users,${local.samba_basedn}"
  description = "DN used to search for LDAP users"
}

output "samba_groupdn" {
  value       = "CN=Users,${local.samba_basedn}"
  description = "DN used to search for LDAP groups"
}

output "samba_cert" {
  value       = tls_locally_signed_cert.samba.cert_pem
  description = "PEM certificate used by Samba and the one that Vault needs to trust"
}

output "samba_url" {
  value       = "ldap://${var.samba_hostname}.${var.samba_domain}"
  description = "URL for connecting to Samba LDAP service"
}

output "z_summary" {
  value = <<EOF

Bastion server:
- SSH user: ${local.ssh_user}
- Public IP: ${join(", ", module.ec2_bastion.public_ip)}

Vault servers:
- SSH user: ${local.ssh_user}
- Private IPs: ${join(", ", module.ec2_vault.private_ip)}
- URL: https://${module.elb.this_lb_dns_name}:${var.vault_port}

Samba server:
- SSH user: ${local.ssh_user}
- Private IP: ${join(", ", module.ec2_samba.private_ip)}
EOF
}
