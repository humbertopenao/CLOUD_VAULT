variable "tags" {
  default = {
    comment = "Infrastructure for Hashicorp Vault service"
  }
}

variable "zone_names" {
  default     = []
  description = "List of 3 desired zones. If omitted, 3 are chosen automatically"
}


variable "public_sshkey" {
  description = "SSH public key to associate to EC2 instances. Mandatory to be defined"
}

variable "internal_lb" {
  default     = true
  description = "For security reasons, it should always be set to true. Only set it to false for testing purposes"
}

variable "git_repo" {
  default     = "https://gitlab.com/arengifoc/vault-with-iac"
  description = "Where to get ansible code from"
}

variable "vault_version" {
  default     = "1.5.5"
  description = "1.6.x is not yet supported with wildcard certificates used by these terraform configurations"
}

variable "vault_domain" {
  default     = "mydomain.com"
  description = "DNS domain associated to Vault nodes and TLS certificate"
}

variable "vault_ldap_user" {
  default     = "vault"
  description = "AD user that Vault will use to bind to the Samba LDAP service"
}

variable "vault_num_nodes" {
  default     = 3
  description = "Number of Vault nodes to be part of the cluster"
}

variable "samba_domain" {
  default     = "example.com"
  description = "AD domain used by the Samba server"
}

variable "samba_vaultadmin_group" {
  default     = "sysadmins"
  description = "AD group which should be mapped to a Vault policy with full admin privileges"
}

variable "samba_vaultadmin_user" {
  default     = "user01"
  description = "AD user which belongs to the AD group with admin privileges in Vault"
}

variable "vault_audit_dir" { default = "/var/vault/log" }
variable "vault_audit_file" { default = "audit_log.json" }
variable "samba-vm-name" { default = "samba-ad-dc" }
variable "samba-vm-size" { default = "t3a.small" }
variable "samba_hostname" { default = "dc1" }
variable "vault-vm-name" { default = "vault" }
variable "vault-vm-size" { default = "t3a.small" }
variable "vault_port" { default = "8200" }
variable "network_name" { default = "vault-network" }
variable "network_cidr" { default = "10.0.0.0/16" }
variable "public_subnet_cidrs" { default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] }
variable "private_subnet_cidrs" { default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"] }
variable "bastion-vm-name" { default = "bastion" }
variable "bastion-vm-size" { default = "t3a.small" }
variable "bastion-vm-userdata" { default = null }
variable "aws_region" { default = "us-east-1" }
variable "aws_access_key" {}
variable "aws_secret_key" {}
