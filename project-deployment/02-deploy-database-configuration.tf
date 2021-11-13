# Deploy nextcloud database
###########################

module "deploy-nextcloud-database-and-user" {
  source = "../../ryo-mariadb/module-deployment/modules/deploy-mysql-db-and-user"
  
  mysql_db_name = "nextcloud"
  mysql_db_default_charset = "utf8mb4"
  mysql_db_default_collation = "utf8mb4_general_ci"
  mysql_db_user = "nextcloud-db-user"
  mysql_db_user_hosts = [ "localhost", join(".", [ local.lxd_host_network_part, "%" ])]
  mysql_db_user_password = local.mariadb_nextcloud_user_password
  mysql_db_table = "*"
  mysql_db_privileges = [ "ALL" ]
}
