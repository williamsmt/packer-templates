# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include .secrets
export $(shell sed 's/=.*//' .secrets)

test:
	env

clean:
	rm -rf ansible-playbooks/

generate-keys:
	mkdir keys
	ssh-keygen -t rsa -N '' -f keys/id_rsa

install-ansible-playbook:
	git clone git@github.com:williamsmt/ansible-playbooks.git

packer-build-ubuntu1804-vmware:
	$(MAKE) install-ansible-playbook
	packer build -var-file=./vars/global.json -var-file=./vars/general-linux.json -only=vsphere-iso ubuntu-1804.json
	$(MAKE) clean

packer-build-ubuntu2004-vmware:
	$(MAKE) install-ansible-playbook
	packer build -var-file=./vars/global.json -var-file=./vars/general-linux.json -only=vsphere-iso ubuntu-2004.json
	$(MAKE) clean

packer-build-centos7-vmware:
	$(MAKE) install-ansible-playbook
	packer build -var-file=./vars/global.json -var-file=./vars/general-linux.json -only=vsphere-iso centos-7.json
	$(MAKE) clean

packer-build-centos8-vmware:
	$(MAKE) install-ansible-playbook
	packer build -var-file=./vars/global.json -var-file=./vars/general-linux.json -only=vsphere-iso centos-8.json
	$(MAKE) clean

packer-build-win2019-vmware:
	packer build -var-file=./vars/global.json -var-file=./vars/general-windows.json -only=vsphere-iso winserv-2019.json
