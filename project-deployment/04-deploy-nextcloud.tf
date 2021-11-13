# Deploy nextcloud server
#########################

resource "lxd_container" "nextcloud" {

  depends_on = [ module.deploy-nextcloud-database-and-user ]
  
  remote     = var.host_id
  name       = "nextcloud"
  image      = join("-", [ local.project_id, "nextcloud", var.image_version ])
  profiles   = ["default"]
  
  config = { 
    "security.privileged": "false"
    "user.user-data" = file("cloud-init/cloud-init-nextcloud.yml")
  }
  
  # Provide eth0 interface with dynamic IP address
  device {
    name = "eth0"
    type = "nic"
    
    properties = {
      name           = "eth0"
      network        = var.host_id
    }
  }
  
  # Mount container directory for persistent storage for nextcloud configuration
  device {
    name = "nextcloud-config"
    type = "disk"
    
    properties = {
      source   = join("", [ "/var/containers/", local.project_id, "/nextcloud/config" ])
      path     = join("", [ "/var/www/", local.project_nextcloud_domain_name, "/nextcloud/config" ])
      readonly = "false"
      shift    = "true"
    }
  }
  
  # Mount container directory for persistent storage for nextcloud data
  device {
    name = "nextcloud-data"
    type = "disk"
    
    properties = {
      source   = join("", [ "/var/containers/", local.project_id, "/nextcloud/data" ])
      path     = join("", [ "/var/www/", local.project_nextcloud_domain_name, "/nextcloud-data" ])
      readonly = "false"
      shift    = "true"
    }
  } 
  
  # Mount container directory for persistent storage for nextcloud custom apps
  device {
    name = "nextcloud-capps"
    type = "disk"
    
    properties = {
      source   = join("", [ "/var/containers/", local.project_id, "/nextcloud/custom_apps" ])
      path     = join("", [ "/var/www/", local.project_nextcloud_domain_name, "/nextcloud/apps-custom" ])
      readonly = "false"
      shift    = "true"
    }
  } 
}
