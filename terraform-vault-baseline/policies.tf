resource "vault_policy" "vault_admin" {
  name   = "vault_admin"
  policy = <<EOF
path "*" {
  capabilities = ["list", "read", "create", "update", "delete", "sudo"]
}
EOF
}

resource "vault_policy" "jenkins" {
  name   = "jenkins"
  policy = <<EOF
path "/jenkins/*" {
  capabilities = ["list", "read", "create", "update", "delete"]
}
EOF
}
