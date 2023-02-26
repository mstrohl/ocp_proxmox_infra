{% set listMasters = (ocp_proxmox_infra_master_list | default(groups["masters"]) ) %}
{% if "workers" in groups -%}
{% set listWorkers = (ocp_proxmox_infra_worker_list | default(groups["workers"]) ) %}
{% endif -%}
resource "proxmox_vm_qemu" "bootstrap" {
  name        = "bootstrap"
  target_node = "{{ ocp_proxmox_infra_server.split('.')[0] }}"
  vmid        = "{{ bootstrap_resources.vmid | default('999')}}"
  onboot      = true
  iso         = "{{ ocp_proxmox_infra_iso_volume }}:iso/{{ ocp_proxmox_infra_iso_type | default('custom')}}-bootstrap-{{ ocp_proxmox_infra_bootstrap_node | default(groups['bootstrap'][0].split('.')[0]) }}-{{ _iso_output_version }}.iso"
  memory      = "{{ bootstrap_resources.ram | default('4096')}}"
  cores       = "{{ bootstrap_resources.cpu | default('2')}}"
  tags        = "bootstrap"

  network {
    model     = "virtio"
    bridge    = "vmbr2"
{% if hostvars["bootstrap"].mac | default(false) %}
    macaddr   = "{{ hostvars["bootstrap"].mac }}"
{% endif %}
  }

  disk {
    type      = "scsi"
    storage   = "local"
    size      = "100G"
    format    = "qcow2"
  }

  timeouts {
    create = "5m"
    delete = "15m"
  }

}
{% for master in listMasters -%}
resource "proxmox_vm_qemu" "master{{ loop.index }}" {
  name        = "{{ master.split('.')[0] }}"
  target_node = "{{ ocp_proxmox_infra_server.split('.')[0] }}"
  vmid        = "{{ ocp_proxmox_infra_masters_id_prefix | default('40') }}{{ loop.index }}"
  onboot      = true
  oncreate    = false
  iso         = "{{ ocp_proxmox_infra_iso_volume }}:iso/{{ ocp_proxmox_infra_iso_type | default('custom')}}-master-{{ master.split('.')[0] }}-{{ _iso_output_version }}.iso"
  memory      = "{{ masters_resources.ram | default('4096')}}"
  cores       = "{{ masters_resources.cpu | default('2')}}"
  tags        = "{{ master.split('.')[0] }}"
  depends_on = [proxmox_vm_qemu.bootstrap]

  network {
{% if hostvars[master].mac1 | default(false) %}
    macaddr   = "{{ hostvars[master].mac1 }}"
{% endif %}
    model     = "virtio"
    bridge    = "vmbr2"   
  }

  network {
{% if hostvars[master].mac2 | default(false) %}
    macaddr   = "{{ hostvars[master].mac2 }}"
{% endif %}
    model     = "virtio"
    bridge    = "vmbr2"   
  }

  disk {
    type      = "scsi"
    storage   = "local"
    size      = "200G"
    format    = "qcow2"
  }

}
{% endfor -%}

{% if "workers" in groups -%}
{% for worker in listWorkers -%}
resource "proxmox_vm_qemu" "worker{{ loop.index }}" {
  name        = "{{ worker.split('.')[0] }}"
  target_node = "{{ ocp_proxmox_infra_server.split('.')[0] }}"
  vmid        = "{{ ocp_proxmox_infra_workers_id_prefix | default('50') }}{{ loop.index }}"
  onboot      = true
  oncreate    = false
  iso         = "{{ ocp_proxmox_infra_iso_volume }}:iso/{{ ocp_proxmox_infra_iso_type | default('custom')}}-worker-{{ worker.split('.')[0] }}-{{ _iso_output_version }}.iso"
  memory      = "{{ workers_resources.ram | default('4096')}}"
  cores       = "{{ workers_resources.cpu | default('2')}}"
  tags        = "{{ worker.split('.')[0] }}"
  depends_on = [proxmox_vm_qemu.bootstrap]

  network {
    model     = "virtio"
    bridge    = "vmbr2"
{% if hostvars[worker].mac1 | default(false) %}
    macaddr   = "{{ hostvars[worker].mac1 }}"
{% endif %}
  }

  network {
    model     = "virtio"
    bridge    = "vmbr2"
{% if hostvars[worker].mac2 | default(false) %}
    macaddr   = "{{ hostvars[worker].mac2 }}"
{% endif %}
  }

  disk {
    type      = "scsi"
    storage   = "local"
    size      = "200G"
    format    = "qcow2"
  }

}
{% endfor -%}
{% endif -%}