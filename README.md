<!--
SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Roll Your Own Nextcloud Server

This is a [rollyourown.xyz project](https://rollyourown.xyz/rollyourown/projects/) to deploy a [Nextcloud](https://nextcloud.com/) server using Ansible, Packer and Terraform.

## Project Summary

This project uses [Ansible](https://www.ansible.com/), [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/) to deploy a [Nextcloud](https://nextcloud.com/) server, with a [MariaDB](https://mariadb.org/) backend database, [HAProxy](https://www.haproxy.org/) for TLS/SSL termination and [Certbot](https://certbot.eff.org/) for managing your [Let's Encrypt](https://letsencrypt.org/) certificate.

## How to Use

A detailed description of how to use a rollyourown.xyz project to deploy and maintain an open source solution can be found [on the rollyourown.xyz website](https://rollyourown.xyz/rollyourown/how_to_use/).

In summary, to deploy a project:

1. Acquire [a domain](https://rollyourown.xyz/rollyourown/how_to_use/deploy/#a-domain) to use for your project, or re-use a domain you already own

2. Prepare a [control node](https://rollyourown.xyz/rollyourown/how_to_use/control_node/) with the basic software to run the rollyourown automation scripts, or use an existing control node you have previously set up

3. Prepare a [host server](https://rollyourown.xyz/rollyourown/how_to_use/host_server/) for deploying the project to, or use an existing host server you have previously set up

4. Enter the working directory (e.g. `~/ryo-projects`) on the control node and clone the project repository from [Codeberg](https://codeberg.org/) or [GitHub](https://github.com/)

        cd ~/ryo-projects
        git clone https://codeberg.org/rollyourown-xyz/ryo-nextcloud.git

    or

        cd ~/ryo-projects
        git clone https://github.com/rollyourown-xyz/ryo-nextcloud.git

5. Copy the project's configuration file and add settings

        cd ~/ryo-projects/ryo-nextcloud
        cp configuration/configuration_TEMPLATE.yml configuration/configuration_<HOST_NAME>.yml
        nano configuration/configuration_<HOST_NAME>.yml

6. Run the deployment script from the project directory

        cd ~/ryo-projects/ryo-nextcloud
        ./deploy.sh -n <HOST_NAME> -v <VERSION>

## How to Collaborate

We would be delighted if you would like to contribute to rollyourown and there are a number of ways you can collaborate on this project:

- [Raising security-related issues](https://rollyourown.xyz/collaborate/security_vulnerabilities/)
- [Contributing bug reports, feature requests and ideas](https://rollyourown.xyz/collaborate/bug_reports_feature_requests_ideas/)
- [Improving the project](https://rollyourown.xyz/collaborate/existing_projects_and_modules/) - e.g. to provide fixes or enhancements

You may also like to contribute to the wider rollyourown project by, for example:

- [Contributing a new project or module](https://rollyourown.xyz/collaborate/new_projects_and_modules/)
- [Contributing to the rollyourown.xyz website content](https://rollyourown.xyz/collaborate/website_content/) or [design](https://rollyourown.xyz/collaborate/website_design/)
- [Maintaining a rollyourown.xyz repository](https://rollyourown.xyz/collaborate/working_with_git/what_is_git/#project-maintainer)

Issues for this project can be submitted on [Codeberg](https://codeberg.org/) (_preferred_) or [GitHub](https://github.com/):

- Issues on Codeberg: [here](https://codeberg.org/rollyourown-xyz/ryo-nextcloud/issues)
- Issues on GitHub: [here](https://github.com/rollyourown-xyz/ryo-nextcloud/issues)

## Security Vulnerabilities

If you have found a security vulnerability in any rollyourown service or any of the rollyourown projects, modules or other repositories, please read our [security disclosure policy](https://rollyourown.xyz/collaborate/security_vulnerabilities/) and report this via our [security vulnerability report form](https://forms.rollyourown.xyz/security-vulnerability).

## Repository Links

For public contributions, we maintain mirror repositories of this project on [Codeberg](https://codeberg.org) and [GitHub](https://github.com):

- [https://codeberg.org/rollyourown-xyz/ryo-nextcloud](https://codeberg.org/rollyourown-xyz/ryo-nextcloud)
- [https://github.com/rollyourown-xyz/ryo-nextcloud](https://github.com/rollyourown-xyz/ryo-nextcloud)

Our preferred collaboration space is Codeberg:

<a href="https://codeberg.org/rollyourown-xyz/ryo-nextcloud"><img alt="Get it on Codeberg" src="https://get-it-on.codeberg.org/get-it-on-blue-on-white.png" height="60"></a>

The primary repository for this project is hosted on our own Git repository server at:

- [https://git.rollyourown.xyz/ryo-projects/ryo-nextcloud](https://git.rollyourown.xyz/ryo-projects/ryo-nextcloud)

**Repositories on our own Git server are accessible only to members of our organisation**.

## Copyright, Licences and Trademarks

For information on copyright, licences and trademarks, see [https://rollyourown.xyz/about/copyright_licenses_trademarks/](https://rollyourown.xyz/about/copyright_licenses_trademarks/).
