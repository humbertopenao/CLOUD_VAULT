resource "vault_generic_secret" "api_creds" {
  path      = "${vault_mount.kv_jenkins.path}/api_creds"
  data_json = <<EOF
{
  "user": "******",
  "password": "******"
}
EOF
}

resource "vault_generic_secret" "db_creds" {
  path      = "${vault_mount.kv_jenkins.path}/db_creds"
  data_json = <<EOF
{
  "user": "******",
  "password": "******"
}
EOF
}