terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.11"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://{{ ocp_proxmox_infra_server }}:8006/api2/json"
  pm_timeout = "1200"
}