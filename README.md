# Managing Vault using IaC
- This repository contains the documentation and code required to deploy and configure Hashicorp Vault using different IaC tools, according to the presentation "Despliegue de HashiCorp Vault usando IaC" at [HashiTalks: America Latina](https://events.hashicorp.com/hashitalkslatinamerica) on November 18, 2020
----

## Workflow
1. Deploy AWS infrastructure for Vault using Terraform code from [terraform-infra-vault](aws-vault-cluster)
2. Install Vault using Ansible code from [ansible-install-vault](ansible-install-vault) (done automatically)
3. SSH into bastion host by looking into `terraform output` from step N° 1
4. Get the initial root token by looking at `~/vault-init-info.txt` file
5. Set `vault_token` variable and configure Vault using Terraform code from [terraform-vault-baseline](terraform-vault-baseline)