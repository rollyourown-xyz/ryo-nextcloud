# ryo-project-template

Template folder structure for a rollyourown.xyz project.

## How to use

Clone this repository as a starting point for a new project and make the following changes:

- In `configuration/configuration_TEMPLATE.yml`, add additional parameters needed for the project
- Add additional Ansible playbooks, roles and tasks for project-specific host setup in the `host-setup` directory
- Add Packer templates for each project component in the `image-build` directory
- Add Ansible playbooks for each component in the `image-build/playbooks` directory with Ansible roles and tasks for the component in the `image-build/playbooks/roles/` directory
- Add terraform files, cloud-init files and additional modules if necessary in the `project-deployment` directory
