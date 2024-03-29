# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Deploy nextcloud database
###########################

module "deploy-nextcloud-database-and-user" {
  source = "../../ryo-mariadb/module-deployment/modules/deploy-mysql-db-and-user"
  
  mysql_db_name = "nextcloud"
  mysql_db_default_charset = "utf8mb4"
  mysql_db_default_collation = "utf8mb4_general_ci"
  mysql_db_user = "nextcloud-db-user"
  mysql_db_user_hosts = [ "localhost", join(".", [ local.lxd_host_network_part, "%" ]), join("", [ local.lxd_host_ipv6_prefix, "::", local.lxd_host_network_ipv6_subnet, ":%" ]) ]
  mysql_db_user_password = local.mariadb_nextcloud_user_password
  mysql_db_table = "*"
  mysql_db_privileges = [ "ALL" ]
}
