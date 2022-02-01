# Deploy Ingress Proxy configuration for nextcloud
##################################################

module "deploy-nextcloud-ingress-proxy-backend-service" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-backend-services"

  depends_on = [ lxd_container.nextcloud ]

  non_ssl_backend_services     = [ "nextcloud" ]
}

module "deploy-nextcloud-ingress-proxy-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-nextcloud-ingress-proxy-backend-service ]

  ingress-proxy_host_only_acls = {
    host-nextcloud = {host = local.project_nextcloud_domain_name}
  }

  ingress-proxy_acl_use-backends = {
    host-nextcloud = {backend_service = "nextcloud"}
  }
}