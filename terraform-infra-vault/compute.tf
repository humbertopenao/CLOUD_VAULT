resource "aws_key_pair" "keypair" {
  key_name_prefix = "vault"
  public_key      = var.public_sshkey
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

module "ami" {
  source = "git::https://gitlab.com/arengifoc/terraform-aws-data-amis"
  os     = "Ubuntu Server 18.04"
}

module "sg_bastion" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.16.0"

  name         = "sg_bastion"
  description  = "SG for bastion hosts"
  vpc_id       = module.network.vpc_id
  egress_rules = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH service"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"

  instance_count              = 1
  name                        = var.bastion-vm-name
  ami                         = module.ami.id
  instance_type               = var.bastion-vm-size
  key_name                    = aws_key_pair.keypair.key_name
  monitoring                  = false
  vpc_security_group_ids      = [module.sg_bastion.this_security_group_id]
  subnet_ids                  = module.network.public_subnets
  associate_public_ip_address = true
  tags                        = var.tags
  user_data                   = templatefile("${path.module}/templates/bastion_setup.tpl", local.bastion_tpl_vars)
  depends_on = [
    module.ec2_vault
  ]
}

module "sg_vault" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.16.0"

  name         = "sg_vault"
  description  = "SG for vault hosts"
  vpc_id       = module.network.vpc_id
  egress_rules = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      description = "Vault ports allowed"
      cidr_blocks = var.internal_lb == true ? module.network.vpc_cidr_block : "0.0.0.0/0"
    },
    {
      from_port   = 8200
      to_port     = 8201
      protocol    = "tcp"
      description = "Vault cluster ports allowed"
      cidr_blocks = module.network.vpc_cidr_block
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH service"
      cidr_blocks = module.network.vpc_cidr_block
    }
  ]
}

module "ec2_vault" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"

  instance_count              = var.vault_num_nodes
  name                        = var.vault-vm-name
  ami                         = module.ami.id
  instance_type               = var.vault-vm-size
  key_name                    = aws_key_pair.keypair.key_name
  monitoring                  = false
  vpc_security_group_ids      = [module.sg_vault.this_security_group_id]
  subnet_ids                  = module.network.private_subnets
  associate_public_ip_address = false
  tags                        = var.tags
  user_data                   = <<EOF
#!/bin/bash
echo "${tls_private_key.this.public_key_openssh}" >> /home/${local.ssh_user}/.ssh/authorized_keys
echo "${module.ec2_samba.private_ip[0]} ${var.samba_hostname}.${var.samba_domain}" >> /etc/hosts
EOF
}

module "sg_samba" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.16.0"

  name         = "sg_samba"
  description  = "SG for samba hosts"
  vpc_id       = module.network.vpc_id
  egress_rules = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 389
      to_port     = 389
      protocol    = "tcp"
      description = "Samba LDAP ports allowed"
      cidr_blocks = module.network.vpc_cidr_block
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH service"
      cidr_blocks = module.network.vpc_cidr_block
    }
  ]
}

resource "random_password" "samba_admin" {
  length      = 20
  special     = false
  upper       = true
  lower       = true
  number      = true
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

resource "random_password" "samba_vaultadmin_password" {
  length  = 20
  special = false
}

resource "random_password" "vault_ldap_user" {
  length  = 20
  special = false
}

module "ec2_samba" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"

  instance_count              = 1
  name                        = var.samba-vm-name
  ami                         = module.ami.id
  instance_type               = var.samba-vm-size
  key_name                    = aws_key_pair.keypair.key_name
  monitoring                  = false
  vpc_security_group_ids      = [module.sg_samba.this_security_group_id]
  subnet_ids                  = module.network.private_subnets
  associate_public_ip_address = false
  tags                        = var.tags
  user_data                   = templatefile("${path.module}/templates/samba_setup.tpl", local.samba_tpl_vars)
}
