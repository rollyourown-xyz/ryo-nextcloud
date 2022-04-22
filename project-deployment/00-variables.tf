# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Input Variables
#################

variable "host_id" {
  description = "Mandatory: The host_id on which to deploy the project."
  type        = string
}

variable "image_version" {
  description = "Version of the images to deploy - Leave blank for 'terraform destroy'"
  type        = string
}

# Local variables
#################

# Configuration file paths
locals {
  project_configuration                = join("", ["${abspath(path.root)}/../configuration/configuration_", var.host_id, ".yml"])
  host_configuration                   = join("", ["${abspath(path.root)}/../../ryo-host/configuration/configuration_", var.host_id, ".yml" ])
  mariadb_terraform_user_password_file = join("", [ "${abspath(path.root)}/../../ryo-mariadb/configuration/mariadb_terraform_user_password_", var.host_id, ".yml" ])
  mariadb_nextcloud_user_password_file = join("", [ "${abspath(path.root)}/../configuration/mariadb_nextcloud_user_password_", var.host_id, ".yml" ])
}

# Basic project variables
locals {
  project_id                    = yamldecode(file(local.project_configuration))["project_id"]
  project_nextcloud_domain_name = yamldecode(file(local.project_configuration))["project_nextcloud_domain_name"]
  project_admin_email           = yamldecode(file(local.project_configuration))["project_admin_email"]
}

# Sensitive variables
locals {
  project_admin_password          = sensitive(yamldecode(file(local.project_configuration))["project_admin_password"])
  project_smtp_server_password    = sensitive(yamldecode(file(local.project_configuration))["project_smtp_server_password"])
  mariadb_terraform_user_password = sensitive(yamldecode(file(local.mariadb_terraform_user_password_file))["mariadb_terraform_user_password"])
  mariadb_nextcloud_user_password = sensitive(yamldecode(file(local.mariadb_nextcloud_user_password_file))["mariadb_nextcloud_user_password"])
}

# LXD variables
locals {
  lxd_host_public_ipv6          = yamldecode(file(local.host_configuration))["host_public_ipv6"]
  lxd_host_control_ipv4_address = yamldecode(file(local.host_configuration))["host_control_ip"]
  lxd_host_network_part         = yamldecode(file(local.host_configuration))["lxd_host_network_part"]
  lxd_host_public_ipv6_address  = yamldecode(file(local.host_configuration))["host_public_ipv6_address"]
  lxd_host_public_ipv6_prefix   = yamldecode(file(local.host_configuration))["host_public_ipv6_prefix"]
  lxd_host_private_ipv6_prefix  = yamldecode(file(local.host_configuration))["lxd_host_private_ipv6_prefix"]
  lxd_host_network_ipv6_subnet  = yamldecode(file(local.host_configuration))["lxd_host_network_ipv6_subnet"]
}

# Calculated variables
locals {
  lxd_host_ipv6_prefix = ( local.lxd_host_public_ipv6 == true ? local.lxd_host_public_ipv6_prefix : local.lxd_host_private_ipv6_prefix )
}

# Consul variables
locals {
  consul_ip_address  = join("", [ local.lxd_host_ipv6_prefix, "::", local.lxd_host_network_ipv6_subnet, ":1" ])
}
