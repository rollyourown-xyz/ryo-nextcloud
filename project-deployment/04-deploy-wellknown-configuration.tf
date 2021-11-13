# Deploy wellknown configuration for the project
################################################

module "deploy-nextcloud-wellknown-configuration" {
  source = "../../ryo-wellknown/module-deployment/modules/deploy-wellknown-configuration"
  
  wellknown_redirect_rules = {
  
    nextcloud-carddav = {
      wellknown_domain       = local.project_nextcloud_domain_name,
      wellknown_path         = "/.well-known/carddav",
      wellknown_redirect_url = join("", [ "https://", local.project_nextcloud_domain_name, "/remote.php/dav" ])
    },
    
    nextcloud-caldav = {
      wellknown_domain       = local.project_nextcloud_domain_name,
      wellknown_path         = "/.well-known/caldav",
      wellknown_redirect_url = join("", [ "https://", local.project_nextcloud_domain_name, "/remote.php/dav" ])
    }
  }
}
