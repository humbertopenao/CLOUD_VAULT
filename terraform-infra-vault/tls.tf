# CA private key
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Vault private key
resource "tls_private_key" "vault" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Samba private key
resource "tls_private_key" "samba" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Certification Authority to sign Vault and Samba certificates
resource "tls_self_signed_cert" "ca" {
  key_algorithm         = tls_private_key.ca.algorithm
  private_key_pem       = tls_private_key.ca.private_key_pem
  validity_period_hours = "8760" # 1 year
  is_ca_certificate     = true
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "cert_signing"
  ]
  subject {
    common_name         = "ca.${var.vault_domain}"
    country             = "PE"
    locality            = "Lima"
    province            = "Lima"
    organization        = "CA Vault"
    organizational_unit = "TI"
  }
}

resource "tls_cert_request" "vault" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.vault.private_key_pem

  subject {
    common_name         = "*.${var.vault_domain}"
    country             = "PE"
    locality            = "Lima"
    province            = "Lima"
    organization        = "Vault"
    organizational_unit = "TI"
  }
}

resource "tls_cert_request" "samba" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.samba.private_key_pem

  subject {
    common_name         = "${var.samba_hostname}.${var.samba_domain}"
    country             = "PE"
    locality            = "Lima"
    province            = "Lima"
    organization        = "Samba"
    organizational_unit = "TI"
  }
}

# Vault certificate
resource "tls_locally_signed_cert" "vault" {
  cert_request_pem      = tls_cert_request.vault.cert_request_pem
  ca_key_algorithm      = "RSA"
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = "8760" # 1 year
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

# Samba certificate
resource "tls_locally_signed_cert" "samba" {
  cert_request_pem      = tls_cert_request.samba.cert_request_pem
  ca_key_algorithm      = "RSA"
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = "8760" # 1 year
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}
