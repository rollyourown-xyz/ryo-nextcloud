# Terraform providers required to deploy this project
# lxd provider will always be used
#
# consul provider is common to almost all project, to 
# enable provisioning of the host consul service
# Remove if not needed for this project 
#####################################################

terraform {
  required_version = ">= 0.15"
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 1.5.0"
    }
    consul = {
      source = "hashicorp/consul"
      version = "~> 2.12.0"
    }
  }
}

provider "lxd" {

  config_dir                   = "$HOME/snap/lxd/common/config"
  generate_client_certificates = false
  accept_remote_certificate    = false

  lxd_remote {
    name     = var.host_id
    default  = true
  }
}

provider "consul" {
  address    = join("", [ local.consul_ip_address, ":8500" ])
  scheme     = "http"
  datacenter = var.host_id
}
