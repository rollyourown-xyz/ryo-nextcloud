# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Terraform providers required to deploy this project
# lxd provider will always be used
#
# consul provider is needed to enable provisioning of the host consul service
# mysql provider is needed to enable provisioning of the nextcloud database
#################################################################################

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
    mysql = {
      source  = "terraform-providers/mysql"
      version = ">= 1.5"
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

provider "mysql" {
  endpoint = join("", [ local.mariadb_ip_address, ":3306" ])
  username = "terraform"
  password = local.mariadb_terraform_user_password
}
