#!/usr/bin/env bash
repo_workdir=/tmp/ansible-setup

# wait for reliable internet connection
failed=1
while [ $failed -ne 0 ]
do
  ping -c 1 8.8.8.8 > /dev/null 2>&1
  failed=$?
  echo "Waiting for Internet connection being ready..."
  sleep 1
done

# Install required OS dependencies
apt-get update
apt-get install -y software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible git netcat-traditional

failed=1
while [ $failed -ne 0 ]
do
  exit=0
  for vault_node in ${join(" ", vault_ips)}
  do
    nc -zw 1 $vault_node 22
    exit=$(($exit+$?))
  done
  failed=$exit
  echo "Waiting for hosts ${join(", ", vault_ips)} to have SSH ready"
  sleep 1
done

# Setup SSH private key
cat > /home/${ssh_user}/.ssh/id_rsa <<EOF
${ssh_priv_key}
EOF
chmod 600 /home/${ssh_user}/.ssh/id_rsa
chown --reference=/home/${ssh_user} /home/${ssh_user}/.ssh/id_rsa

# Clone git repo
su - ${ssh_user} -c "mkdir -p $repo_workdir"
su - ${ssh_user} -c "cd $repo_workdir ; git clone ${git_repo} ."

# Populate Ansible inventory file
cat > $repo_workdir/ansible-install-vault/hosts <<EOF
[vault]
%{ for ip in vault_ips ~}
vault${index(vault_ips, ip)+1} ansible_host=${ip}
%{ endfor ~}

[all:vars]
#ansible_user: ubuntu
#ansible_ssh_common_args: '-o ProxyCommand="ssh -W %h:%p -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@<BASTION-HOST>"'

EOF

cat >> $repo_workdir/ansible-install-vault/vars.yml <<EOF
%{ for key, value in vault_vars ~}
${yamlencode({"${key}":"${value}"})}
%{ endfor ~}
EOF

# Deploy ansible playbook
su - ${ssh_user} -c "cd $repo_workdir/ansible-install-vault ; ansible-playbook site.yml"
