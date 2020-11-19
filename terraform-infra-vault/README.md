# terraform-infra-vault
These terraform configuration files create the following infrastructure resources on AWS:

- Network
    + 01 VPC
    + 06 Subnets (3 private and 3 public subnets distributed in 3 AZs)
    + 01 NAT Gateway (one for all three subnets)
    + 01 Internet Gateway
    + Security Groups
- Virtual Machines
    + 01 EC2 instance as Bastion host
    + 03 EC2 instances as Vault nodes (on private subnets)
    + 01 EC2 instance as Samba server (AD domain controller)
    + 01 SSH Keypair (using a imported public SSH key)
- Load Balancers
    + 01 Network Load Balancer (3 Vault nodes as part of their target group)
- Other resources
    + Random passwords (used for auto-generated Samba LDAP users)
    + Self-signed TLS certificates (for Samba server)
    + 01 KMS Key (used for Vault auto unsealing)
    + 01 IAM User (whose credentials are used to setup Vault auto unsealing)

Also, it does some interesting integrations by the use of user_data scripts in all EC2 instances, as follows:

- On Samba server
    + By using terraform templating, it creates a bash script to be executed on instance creation
    + This template uses variables defined as `locals { }` under `samba_tpl_vars { }` dictionary
    + It saves the public key in ~/.ssh/authorized_keys of the keypair created as a terraform resource (~ defaults to ubuntu user on Ubuntu Systems)
    + It installs OS packages needed for setting up Samba as AD DC
    + It copies and adjusts certain files needed by Samba
    + It provisions Samba as AD DC with parameters defined in `samba_tpl_vars { }`
    + It creates two AD users: one for Vault binding in LDAP auth method, and one used as demo Vault admin user
    + It creates an AD group which will be mapped to a policy with full admin privileges in Vault
- On Vault nodes
    + It saves the public key in ~/.ssh/authorized_keys of the keypair created as a terraform resource (~ defaults to ubuntu user on Ubuntu Systems)
    + It registers the hostname of Samba AD DC in /etc/hosts
- On Bastion host
    + By using terraform templating, it creates a bash script to be executed on instance creation
    + This template uses variables defined as `locals { }` under `bastion_tpl_vars { }` dictionary
    + It saves the private key in ~/.ssh/id_rsa of the keypair created as a terraform resource (~ defaults to ubuntu user on Ubuntu Systems)
    + It install OS packages needed to automate tasks (ansible, git, etc.)
    + It clones a Git repository using the URL defined in the `git_repo` variable
    + It populates the Ansible inventory file with the IPs of all Vault nodes
    + It populates the Ansible vars.yml variables file with values passed as parameters from `bastion_tpl_vars { vault_vars { } }` dictionary
    + It executes the Ansible site.yml playbook to install, configure, initialize and unseal Vault nodes with code from `ansible-install-vault`


## Architecture
The following diagram summarizes the most important Cloud resources for supporting the Vault cluster

![AWS Infrastructure](resources/terraform-infra-vault.png "AWS diagram")

## Usage
1. Edit backend.tf and set the necessary parameters to point to a valid S3 bucket, key and their AWS credentials.
2. Set values for aws_access_key and aws_secret_key variables required by the aws provider
3. Check variables.tf and made adjustments to variables as needed (using terraform.tfvars or environment variables)
4. Initialize backend and modules by running `terraform init`
5. Plan with `terraform plan` and deploy with `terraform apply`
6. Once `terraform apply` finishes, SSH into bastion host and run `cat vault-init-info.txt`. Take note of the initial root token.
7. Optional: check `/tmp/ansible-setup/ansible-install-vault/ansible.log` for details of the Ansible playbook execution

**Important**: Each of the projects `terraform-infra-vault`, `ansible-install-vault` and `terraform-vault-baseline` have their own README.md with instructions