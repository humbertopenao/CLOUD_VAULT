#!/bin/bash
samba_hostname="${samba_hostname}"
samba_domain="${samba_domain}"
samba_admin_pass="${samba_admin_pass}"
samba_tls_path=/var/lib/samba/private/tls
samba_server_cert="${server_cert}"
samba_server_key="${server_key}"
samba_ca_cert="${ca_cert}"
echo "${pub_sshkey}" >> /home/${ssh_user}/.ssh/authorized_keys
hostnamectl set-hostname $samba_hostname
main_nic=$(ip route show | grep ^default | awk '{ print $5 }')
private_ip=$(ip addr show $main_nic | grep -w inet | cut -d / -f 1 | awk '{ print $2 }')
echo "$private_ip $samba_hostname.$samba_domain" >> /etc/hosts

# wait for reliable internet connection
failed=1
while [ $failed -ne 0 ]
do
  ping -c 1 8.8.8.8 > /dev/null 2>&1
  failed=$?
  echo "Waiting for Internet connection being ready..."
  sleep 1
done

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y samba smbclient winbind libpam-winbind libnss-winbind krb5-kdc libpam-krb5
mv /etc/samba/smb.conf /etc/samba/smb.conf.orig
mv /etc/krb5.conf /etc/krb5.conf.orig
samba-tool domain provision --use-rfc2307 --realm $(echo $samba_domain | tr a-z A-Z) --domain $(echo $samba_domain | cut -d . -f 1) --server-role "dc" --dns-backend "SAMBA_INTERNAL" --adminpass $samba_admin_pass
cp /var/lib/samba/private/krb5.conf /etc
echo "$samba_server_cert" > $samba_tls_path/samba_cert.pem
echo "$samba_server_key" > $samba_tls_path/samba_key.pem
echo "$samba_ca_cert" > $samba_tls_path/ca_cert.pem
chmod 600 $samba_tls_path/samba_key.pem
cp $samba_tls_path/ca_cert.pem /usr/local/share/ca-certificates/samba_ca_cert.crt
update-ca-certificates
sed -i -e "/dns forwarder/s/=.*/= 8.8.8.8/g" /etc/samba/smb.conf
sed -i -e '/global/a\\ttls enabled = yes' /etc/samba/smb.conf
sed -i -e '/tls enabled/a\\ttls keyfile = tls/samba_key.pem' /etc/samba/smb.conf
sed -i -e '/tls keyfile/a\\ttls certfile = tls/samba_cert.pem' /etc/samba/smb.conf
sed -i -e '/tls certfile/a\\ttls cafile = tls/ca_cert.pem' /etc/samba/smb.conf
for service in smbd nmbd winbind systemd-resolved
do
  systemctl disable --now $service
  systemctl mask $service
done
cat > /etc/resolv.conf <<EOF
search $samba_domain
nameserver $private_ip
EOF
systemctl unmask samba-ad-dc
systemctl enable --now samba-ad-dc
samba-tool user create ${vault_ldap_user} ${vault_ldap_password}
samba-tool group add ${samba_vaultadmin_group}
samba-tool user create ${samba_vaultadmin_user} ${samba_vaultadmin_password}
samba-tool group addmembers ${samba_vaultadmin_group} ${samba_vaultadmin_user}
