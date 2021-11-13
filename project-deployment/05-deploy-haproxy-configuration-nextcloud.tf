# Deploy HAProxy configuration for nextcloud
############################################

module "deploy-nextcloud-haproxy-backend-service" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-backend-services"

  non_ssl_backend_services     = [ "nextcloud" ]
}

module "deploy-nextcloud-haproxy-acl-configuration" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-nextcloud-haproxy-backend-service ]

  haproxy_host_only_acls = {
    host-nextcloud = {host = local.project_nextcloud_domain_name}
  }
}

module "deploy-nextcloud-haproxy-backend-configuration" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-nextcloud-haproxy-acl-configuration ]

  haproxy_acl_use-backends = {
    host-nextcloud = {backend_service = "nextcloud"}
  }
}
