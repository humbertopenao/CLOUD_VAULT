# terraform-vault-baseline
These terraform configuration files create the following infrastructure resources on Vault:

- Auth methods
    + 01 LDAP (integrated with Samba AD DC)
    + 01 LDAP group mapped to a full admin privileges policy
    + 01 AppRole (used for demo purposes)
    + AppRole Role ID and Secret ID (shown as output only for testing)
- Policies
    + 01 policy with full admin privileges
    + 01 policy with privileges to KV path

## Usage
1. Get the root token from `terraform-infra-vault` project. Check that directory for instructions.
2. Set the root token as value for the vault_token variable
3. Edit backend.tf and set the necessary parameters to point to a valid S3 bucket, key and their AWS credentials.
4. Check variables.tf and made adjustments to variables as needed (using terraform.tfvars or environment variables)
5. Set the appropriate values for remote_state_* variables which should point to the `terraform-infra-vault` remote state
6. Initialize backend and modules by running `terraform init`
7. Plan with `terraform plan` and deploy with `terraform apply`
