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

#!/bin/bash
#
 # This is the sys_prep script
 # It will clear out all non-revelent information for a new VM

 # 0. Remove old kernels and packages
 yum clean all
 package-cleanup --oldkernels --count=1

 # 1. Force logs to rotate and clear old.
 /usr/sbin/logrotate -f /etc/logrotate.conf
 /bin/rm -f /var/log/*-20* /var/log/*.gz
 #
 # 2. Clear the audit log & wtmp.
 /bin/cat /dev/null > /var/log/audit/audit.log
 /bin/cat /dev/null > /var/log/wtmp
 #
 # 3. Remove the udev device rules.
 /bin/rm -f /etc/udev/rules.d/70*
 #
 # 4. Remove the traces of the template MAC address and UUIDs.
 /bin/sed -i '/^\(HWADDR\|UUID\|IPADDR\|NETMASK\|GATEWAY\)=/d' /etc/sysconfig/network-scripts/ifcfg-e*
 #
 # 5. Clean /tmp out.
 /bin/rm -rf /tmp/*
 /bin/rm -rf /var/tmp/*
 #
 # 6. Remove the SSH host keys.
 /bin/rm -f /etc/ssh/*key*
 #
 # 7. Remove the root user's shell history.
 /bin/rm -f /root/.bash_history
 unset HISTFILE
 #
 # 8. Set hostname to localhost
 /bin/sed -i "s/HOSTNAME=.*/HOSTNAME=localhost.localdomain/g" /etc/sysconfig/network
 /bin/hostnamectl set-hostname localhost.localdomain

 # 9. Clear out the osad-auth.conf file to stop dupliate IDs
 #
 rm -v /etc/sysconfig/rhn/osad-auth.conf
 rm -v /etc/sysconfig/rhn/systemid


 # clean hosts
 #hostname_check=$(hostname)
 #if ! [[ "${hostname_check}" =~ "local" ]]; then
 #	cp -v /etc/hosts /etc/hosts.sys_prep
 #	sed -i "s,$(hostname),,g" /etc/hosts
 #	sed -i "s,$(hostname -s),,g" /etc/hosts
 #fi

 rm -v /root/.ssh/known_hosts

# Lockdown ssh
echo "Disabling password authn to ssh..."
sed -i "/^[^#]*PasswordAuthentication[[:space:]]yes/c\PasswordAuthentication no" /etc/ssh/sshd_config

echo "Clearing Packer user if exists..."
#rm -rf /home/packer/.ssh
usermod -p '!!' packer

echo "Process complete..."
#poweroff
