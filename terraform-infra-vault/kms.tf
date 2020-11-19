resource "aws_kms_key" "vault_key" {
  description             = "KMS key for unsealing Vault"
  deletion_window_in_days = 7
  tags                    = var.tags
}

resource "aws_kms_alias" "vault_key_alias" {
  name_prefix   = "alias/vault_key_"
  target_key_id = aws_kms_key.vault_key.id
}
