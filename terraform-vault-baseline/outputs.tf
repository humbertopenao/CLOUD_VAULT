output "jenkins_role_id" {
  value = data.vault_approle_auth_backend_role_id.jenkins.role_id
}

output "jenkins_wrapping_accessor" {
  value = vault_approle_auth_backend_role_secret_id.jenkins.wrapping_accessor
}

output "jenkins_wrapping_token" {
  value = vault_approle_auth_backend_role_secret_id.jenkins.wrapping_token
}

# output "jenkins_secret_id" {
#   value = vault_approle_auth_backend_role_secret_id.jenkins.secret_id
# }
