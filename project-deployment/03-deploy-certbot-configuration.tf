# Deploy certbot configuration for nextcloud server
###################################################

module "deploy-nextcloud-cert-domains" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-cert-domains"

  certificate_domains = {
    domain_1 = {domain = local.project_nextcloud_domain_name, admin_email = local.project_admin_email},
  }
}
