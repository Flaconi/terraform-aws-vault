#!/usr/bin/env bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and then the run-vault script to configure and start
# Vault in server mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/vault-consul-ami/vault-consul.json.

# Be picky
set -e
set -x

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Install some packages:
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch |\
 apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" |\
 tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update
apt-get install -y software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible filebeat
update-rc.d filebeat defaults 95 10

# Add SSH keys
printf "${ssh_keys}\n" > "/home/${ssh_user}/.ssh/authorized_keys"
chmod 600 "/home/${ssh_user}/.ssh/authorized_keys"
chown ${ssh_user}:${ssh_user} "/home/${ssh_user}/.ssh/authorized_keys"

# The Packer template puts the TLS certs in these file paths
readonly VAULT_TLS_CERT_FILE="/opt/vault/tls/vault.crt.pem"
readonly VAULT_TLS_KEY_FILE="/opt/vault/tls/vault.key.pem"

# Start Consul Client for auto-discovery
/opt/consul/bin/run-consul \
	--client \
	--cluster-tag-key "${consul_cluster_tag_key}" \
	--cluster-tag-value "${consul_cluster_tag_value}"

# Start Vault Server
if [ "${enable_s3_backend}" -eq "1" ]; then
	# Use S3 as storage backend
	/opt/vault/bin/run-vault \
		--tls-cert-file "$VAULT_TLS_CERT_FILE" \
		--tls-key-file "$VAULT_TLS_KEY_FILE" \
		--enable-s3-backend --s3-bucket "${s3_bucket_name}" \
		--s3-bucket-region "${s3_bucket_region}"
else
	# Use Consul as storage backend
	/opt/vault/bin/run-vault \
		--tls-cert-file "$VAULT_TLS_CERT_FILE" \
		--tls-key-file "$VAULT_TLS_KEY_FILE"
fi
