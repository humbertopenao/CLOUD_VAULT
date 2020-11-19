# ansible-install-vault
This directory contains several playbooks and a role which all perform a Hashicorp Vault installation in a 3 or 5 node cluster based on Raft storage backend. These are run from the bastion host pointing to the list of Vault nodes.
This is the list of tasks that are executed by these playbooks:

- It checks and installs some required dependencies (Python and OS packages)
- It saves the private key and certificates as local files under /tmp
- By using the vault-installation role, it installs Ansible and also makes some basic configurations as follows:
    + It creates a user and group for Vault
    + It creates several directories needed by Vault
    + It downloads, extracts and installs Vault binary
    + Adjust some OS settings for Vault (Systemd service and tmpfiles config)
    + Optional: It changes the hostname according to its Ansible inventory hostname
    + If TLS certificates and private key provided, it copies them to appropriate directories
    + It registers the name of Vault nodes in /etc/hosts
    + It creates a Vault config.hcl file with TLS enabled and Auto unsealing with AWS KMS (if their required variables were defined)
    + It defines VAULT_ADDR variable, Vault autocompletion and disables Vault commands history by configuring /etc/profile
    + It disables swap on the system
    + It enables and starts Vault service
- It initializes Vault on the first node only
- If no auto unseal variables were provided, proceed to unseal Vault on each node
- It saves the initialization information (Shamir keys and initial root token) to ~/vault-init-info.txt file in bastion host

**Important**:
- Many of the required or most important variables used by this playbook are already defined in vars.yml. This file is populated automatically by `terraform-infra-vault` with variables such as `server_cert`, `server_key`, `aws_kms_key_id`, among others. 
- Almost all Ansible variables used by these playbooks are defined with default values in `vault-installation/defaults/main.yml`, so it might be important to take a look at it
- If any of these supported Ansible variables need to be modified, it can be done by defining the same name in `terraform-infra-vault/main.tf`, in `locals { }`, under `bastion_tpl_vars { vault_vars { } }` dictionary