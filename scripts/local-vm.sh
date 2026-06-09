#!/usr/bin/env bash
set -euo pipefail

# Provisions a local Ubuntu VM with multipass and configures it end to end with ansible.
# This is the local stand-in for an AWS EC2 instance: same ansible roles, real VM.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VM_NAME="${VM_NAME:-sample-app}"
KEY="${ROOT}/scripts/.vm_key"

command -v multipass >/dev/null || { echo "multipass is required"; exit 1; }

echo "==> generating ephemeral ssh key"
rm -f "$KEY" "$KEY.pub"
ssh-keygen -t ed25519 -N "" -f "$KEY" -q
PUBKEY="$(cat "$KEY.pub")"

CLOUD_INIT="$(mktemp)"
cat > "$CLOUD_INIT" <<EOF
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${PUBKEY}
EOF

echo "==> launching multipass vm: ${VM_NAME}"
if ! multipass info "$VM_NAME" >/dev/null 2>&1; then
  multipass launch 24.04 --name "$VM_NAME" --cpus 2 --memory 4G --disk 20G --cloud-init "$CLOUD_INIT"
fi
rm -f "$CLOUD_INIT"

IP="$(multipass info "$VM_NAME" --format json | python3 -c 'import sys,json; print(json.load(sys.stdin)["info"]["'"$VM_NAME"'"]["ipv4"][0])')"
echo "==> vm ip: ${IP}"

cat > "${ROOT}/ansible/inventory/local.ini" <<EOF
[app]
${VM_NAME} ansible_host=${IP} ansible_user=ubuntu ansible_ssh_private_key_file=${KEY}

[app:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo "==> installing ansible collections"
cd "${ROOT}/ansible"
ansible-galaxy collection install -r requirements.yml >/dev/null

echo "==> waiting for ssh"
for _ in $(seq 1 20); do
  if ssh -i "$KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=3 "ubuntu@${IP}" true 2>/dev/null; then break; fi
  sleep 3
done

echo "==> running playbook"
ansible-playbook -i inventory/local.ini playbook.yml

echo "==> verifying app on the vm"
curl -fsS "http://${IP}:3000/healthz" && echo
curl -fsS "http://${IP}:3000/api/info" && echo

echo "==> done. App is at http://${IP}:3000 . Destroy with: multipass delete ${VM_NAME} && multipass purge"
