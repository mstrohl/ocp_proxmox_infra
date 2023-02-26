# ocp_proxmox_infra

## Description

Ansible role to generate Openshift architecture over proxmox instance.

# Usage

Overwrite vars defined in defaults to fit your needs.
Role based on inventory groups bootstrap, masters and workers

Create playbook:

```
cat << EOF >> proxmox_playbook.yml
---
- name: Manage Openshift Images
  hosts: localhost
  become: true
  roles:
    - role: ocp_proxmox_infra
EOF
```

Execute:

```
ansible-playbook -i inventory iso_playbook.yml
```