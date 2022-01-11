#------------------------------------------------------------------------------
# Packer template for building LXD container image for ryo-nextcloud
# Ubuntu minimal images are used as base images
#------------------------------------------------------------------------------

## Input variables
##

# Specify the host_id for which to build the image
variable "host_id" {
  description = "Mandatory: The host_id for which to build the image."
  type        = string
}

# Specify the version number of the image to be built
variable "version" {
  description = "Mandatory: The version identifier to be added to the output image name."
  type        = string
}

# Specify the nextcloud version to use in the image build
variable "nextcloud_version" {
  description = "Mandatory: The nextcloud version to use in the image build."
  type        = string
}

## Local configuration variables
##

# Name for the container for which the image is to be built
locals {
  service_name = "nextcloud"
}

# Variables from configuration files
locals {
  project_id      = yamldecode(file("${abspath(path.root)}/../configuration/configuration_${var.host_id}.yml"))["project_id"]
  remote_lxd_host = var.host_id
}

## Parameters for the build process
##

locals {
  build_image_os       = "ubuntu-minimal"
  build_image_release  = "focal"
  build_container_name = "packer-lxd-build"

  build_inventory_file    = "${abspath(path.root)}/playbooks/inventory.yml"
  build_playbook_file     = "${abspath(path.root)}/playbooks/provision-nextcloud.yml"

  build_extra_vars        = "host_id=${var.host_id} project_id=${local.project_id} nextcloud_version=${var.nextcloud_version}"
  build_remote_extra_vars = "${ join("", [ "ansible_lxd_remote=", local.remote_lxd_host, " ", local.build_extra_vars ]) }"
}

## Computed local variables
##

# Computed parameters for the output image
locals {
  
  output_image_name        = "${ join("-", [ local.project_id, local.service_name, var.version ]) }"
  
  output_image_description = "${ join(" ", [ 
      join(":", [ local.build_image_os , local.build_image_release ]),
      "image for",
      local.service_name,
      "- v",
      var.version
    ]
  )}"
}

## Build template
##

source "lxd" "container" {
  image          = "${ join(":", [ local.build_image_os , local.build_image_release ]) }"

  publish_properties = {
    description = local.output_image_description
    os          = local.build_image_os
    release     = local.build_image_release
  }
}

build {

  source "lxd.container" {

    ## Build locally
    container_name = local.build_container_name
    output_image   = local.output_image_name

    ## Build on remote
    # container_name = "${ join(":", [ local.remote_lxd_host, local.build_container_name ]) }"
    # output_image   = "${ join(":", [ local.remote_lxd_host, local.output_image_name ]) }"

  }

  provisioner "ansible" {

    inventory_file  = local.build_inventory_file
    playbook_file   = local.build_playbook_file

    ## Build locally
    extra_arguments = [ "--extra-vars", local.build_extra_vars ]

    ## Build on remote
    # extra_arguments = [ "--extra-vars", local.build_remote_extra_vars ]

  }

  ## Use post-processors if build locally, comment out if build on remote
  post-processors {

    # Copy image to remote LXD host
    post-processor "shell-local" {
      inline = [
        "echo \"Copying image ${local.output_image_name} to remote host ${local.remote_lxd_host}\"", 
        "echo \"This may take some time\"",
        "lxc image copy ${local.output_image_name} ${local.remote_lxd_host}: --copy-aliases",
        "echo \"Image copying completed\"",
      ]
      keep_input_artifact = true
    }

    # Post processor for removing image from local machine after copying to remote host
    post-processor "shell-local" {
      inline = [
        "echo \"Deleting local image ${local.output_image_name}\"",
        "lxc image delete ${local.output_image_name}",
        "echo \"Image deletion completed\"",
      ]
      keep_input_artifact = false
    }
  }

}
