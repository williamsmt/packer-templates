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
# Sysprep OS for vmware template creation.
#
#

echo "Removing openssh-server's host keys..."
rm -vf /etc/ssh/ssh_host_*
cat /dev/null > /etc/rc.local
cat << EOF >> /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
#rm -vf /root/vm-dehydrate > /dev/null
test -f /etc/ssh/ssh_host_ecdsa_key || dpkg-reconfigure -f noninteractive openssh-server
exit 0
EOF

echo "Setting execution permission on rc.local..."
chmod +x /etc/rc.local

echo "Cleaning up /var/mail..."
rm -vf /var/mail/*

echo "Clean up apt cache..."
find /var/cache/apt/archives -type f -exec rm -vf \{\} \;

echo "Clean up ntp..."
rm -vf /var/lib/ntp/ntp.drift
rm -vf /var/lib/ntp/ntp.conf.dhcp

echo "Clean up dhcp leases..."
rm -vf /var/lib/dhcp/*.leases*
rm -vf /var/lib/dhcp3/*.leases*

echo "Clean up udev rules..."
rm -vf /etc/udev/rules.d/70-persistent-cd.rules
rm -vf /etc/udev/rules.d/70-persistent-net.rules

echo "Clean up urandom seed..."
rm -vf /var/lib/urandom/random-seed

echo "Clean up backups..."
rm -vrf /var/backups/*;
rm -vf /etc/shadow- /etc/passwd- /etc/group- /etc/gshadow- /etc/subgid- /etc/subuid-

echo "Cleaning up /var/log..."
find /var/log -type f -name "*.gz" -exec rm -vf \{\} \;
find /var/log -type f -name "*.1" -exec rm -vf \{\} \;
find /var/log -type f -exec truncate -s0 \{\} \;

echo "Compacting drive..."
#dd if=/dev/zero of=EMPTY bs=1M > /dev/null
rm -vf /root/EMPTY

echo "Clearing bash history..."
cat /dev/null > /root/.bash_history
history -c

# Reset DUID to prevent dhcp duplicates
echo "Resetting DUID for netplan..."
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Lockdown ssh
echo "Disabling password authn to ssh..."
sed -i "/^[^#]*PasswordAuthentication[[:space:]]yes/c\PasswordAuthentication no" /etc/ssh/sshd_config

echo "Clearing Packer user if exists..."
#rm -rf /home/packer/.ssh
usermod -p '!!' packer

echo "Process complete..."
#poweroff
