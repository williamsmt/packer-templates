# packer-templates

Templates contained in this repository can be used for imaging hybrid cloud instances to run various workloads. The main template json files are located in the root, with dependent variable and configuration files in their respective subdirectories. At a high level, the following must be accomplished prior to deploying a template from this repo:

- Create a .secrets file to hold your CSP credentials
- Download template dependencies (e.g. Ansible Playbooks)
- Amend configuration file variables to desired values
- Run `packer build` to begin deployment process

## Using this repository

Simply clone the repository and start modifying files according to your needs.

```
git clone https://github.com/williamsmt/packer-templates.git packer-templates/
```

Prerequisites:
- Network configuration assumes DHCP is provided to guest
- Connectivity from packer client to Cloud Service Provider API
- Ansible and its dependencies must be installed (if using Ansible provisioner)

### Supported Operating Systems

- [x] Ubuntu Server >= 18.04 LTS
- [x] CentOS >= 7
- [ ] CentOS Stream
- [ ] Windows Server

### Supported Builders

- [x] vsphere-iso
- [ ] vmware-iso
- [ ] Google Cloud
- [ ] Amazon EC2
- [ ] Azure
- [ ] DigitalOcean
- [ ] Vagrant

## Usage

Most templates in this repository contain dependent provisioners that must be available prior to deployment, e.g. Ansible playbooks and roles. The included Makefile provides a convenient mechanism to automate this requirement as exampled below. Variables used in the Ansible provisioner are available in the various var files contained in the vars directory, and will be passed thru as command line --extra-vars to invoke precedence.

The following command block outlines the Makefile structure that clones an Ansible repo dependency for the included Packer templates:

```
install-ansible-playbook:
	git clone git@github.com:williamsmt/ansible-playbooks.git
```

Invoking this block is as simple as `make install-ansible-playbook` from within the packer-template directory, but largely unnecessary unless you are reviewing the provisioner details.

### Independent Run

Make any necessary variable changes within the template and the installed dependencies (see below configuration file table). Once satisfied with defined settings to be applied, templates can be deployed as documented below.

Copy `secrets.example` to `.secrets` and update the variables with corresponding values for CSP authentication. Example `.secrets` for VMware vSphere:

```
VSPHERE_USER=administrator@vsphere.local
VSPHERE_PASS=Password123!
VSPHERE_URL=vcenter.domain.local
```

Confirm you are satisfied with the customization to the relevant configuration files identified below, then deploy the template using the Makefile:

`make packer-build-ubuntu1804-vmware`

## Repository Contents

The following index outlines the file and directory structure of this repository, inclusive of templates, variables, configuration files, and credentials. Links to dependecies include documentation regarding required variables and expected behavior. Please carefully review prior to deploying a template that references said provisioners.

### Templates

The directory structure of this repository:

```
packer-templates/
├── ubuntu-1804.json            Main Packer Template
├── .secrets                    Credentials file for CSP
├── Makefile                    Wrapper script for packer build
├── vars/                       Variable files
│   ├── general-linux.json         OS general template variables
│   └── global.json                Template agnostic variables
├── scripts/                    Post-provisioning tools
│   ├── debian-dehydrate.sh        Generalizes the machine
│   └── debian-rehydrate.sh        Unused for now
└── config/                     Configuration files
    └── preseed.cfg                Linux flavor preseed file
```

Template | Description
-------- | -----------
`ubuntu-1804.json` | Ubuntu Server 18.04
`ubuntu-2004.json` | Ubuntu Server 20.04
`centos-7.json` | CentOS 7
`centos-8.json` | CentOS 8

### Builders

A list of Packer builders and their configuration files:

Builder | Var File | Description
------- | -------- | -----------
`vsphere-iso` | `global.json` | VM template created in vCenter

### Provisioners

A list of Packer provisioners and their configuration files:

Provisioner | Var File | Description
----------- | -------- | -----------
Ansible | `global.json` | Various Ansible baseline [playbooks](https://github.com/williamsmt/ansible-playbooks).

### Other Configuration Files

Various other configuration and variable files:

File | Description
--- | ---
`general-linux.json` | Defines guest specs and Ansible playbook for a general-purpose VM template
`preseed.cfg` | Answer file for Ubuntu installation
`ks.cfg` | Answer file for CentOS installation
`secrets.example` | File holding CSP credentials and should be copied to `.secrets` for use

## License

Released under the [Apache-2.0 license](LICENSE)

## Author Information

https://github.com/williamsmt

This is not an officially supported Google product