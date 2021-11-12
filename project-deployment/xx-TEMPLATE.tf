## TERRAFORM FILE EXAMPLES FOR DEPLOYMENT OF PROJECT COMPONENTS

# Deployment of <COMPONENT_NAME> using a static IP address and a plain cloud-init file
######################################################################################

# resource "lxd_container" "<COMPONENT_NAME>" {
#   remote     = var.host_id
#   name       = "<COMPONENT_NAME>"
#   image      = join("-", [ local.project_id, "<COMPONENT_NAME>", var.image_version ])
#   profiles   = ["default"]
  
#   config = { 
#     "security.privileged": "false"
#     "user.user-data" = file("cloud-init/cloud-init-TEMPLATE.yml")
#   }
  
#   # Provide eth0 interface with dynamic IP address
#   device {
#     name = "eth0"
#     type = "nic"

#     properties = {
#       name           = "eth0"
#       network        = var.host_id
#     }
#   }
  
#   # Mount container directory for persistent storage for grav user data
#   device {
#     name = "<NAME>"
#     type = "disk"
    
#     properties = {
#       source   = join("", [ "/var/containers/", local.project_id, "<SUBDIRECTORY>" ])
#       path     = "<PATH>"
#       readonly = "false"
#       shift    = "true"
#     }
#   }
# }


# Deploy certbot configuration for project domain
#################################################
# module "deploy-<PROJECT_ID>-cert-domains" {
#   source = "../../ryo-service-proxy/module-deployment/modules/deploy-cert-domains"

#   certificate_domains = {
#     domain_1 = {domain = local.project_domain_name, admin_email = local.project_admin_email},
#     domain_2 = {domain = join("", [ "www.", local.project_domain_name]), admin_email = local.project_admin_email}
#   }
# }


# Deploy HAProxy configuration for <COMPONENT_NAME>
###################################################

# module "deploy-<PROJECT_ID>-haproxy-backend-service" {
#   source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-backend-services"
#   non_ssl_backend_services = [ join("-", [ var.host_id, local.project_id, "<SERVICE_NAME>" ]) ]
# }

# module "deploy-<PROJECT_ID>-haproxy-acl-configuration" {
#   source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

#   depends_on = [ module.deploy-<PROJECT_ID>-haproxy-backend-service ]

#   haproxy_host_only_acls = {
#     domain     = {host = local.project_domain_name},
#     domain-www = {host = join("", [ "www.", local.project_domain_name])}
#   }

#   haproxy_host_path_acls = {
#     domain-admin = {host = local.project_domain_name, path = "/admin"},
#   }
# }

# module "deploy-<PROJECT_ID>-haproxy-backend-configuration" {
#   source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

#   depends_on = [ module.deploy-<PROJECT_ID>-haproxy-backend-service ]

#   haproxy_acl_denys = [ "domain-admin" ]

#   haproxy_tcp_listeners = {
#     3022 = {backend_service = join("-", [ local.project_id, "<SERVICE_NAME>" ])},
#     4022 = {backend_service = join("-", [ local.project_id, "<SERVICE_NAME>" ])}
#   }

#   haproxy_acl_use-backends = {
#     domain     = {backend_service = join("-", [ local.project_id, "<SERVICE_NAME>" ])},
#     domain-www = {backend_service = join("-", [ local.project_id, "<SERVICE_NAME>" ])}
#   }
# }