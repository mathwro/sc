#!/bin/bash

#Enabling SUSE SSH Access
#Author: Mathias Wrobel - Innofactor A/S

Changes=$false

echo "Checking status of SSH"
sshstatus=$(systemctl status sshd | grep Active)
if [[ $sshstatus =~ "dead" ]] 
then
    echo "Enabling SSH"
    systemctl enable sshd
    systemctl start sshd
    Changes=$true
fi


echo "Checking status of firewall"
firewallstatus=$(cat /etc/sysconfig/SuSEfirewall2 | grep FW_CONFIGURATIONS_EXT)
if [[ ! $firewallstatus =~ "sshd" ]] 
then
    echo "Configuring SSH firewall rule"
    sed -i 's/FW_CONFIGURATIONS_EXT=""/FW_CONFIGURATIONS_EXT="sshd"/g' /etc/sysconfig/SuSEfirewall2
    Changes=$true
fi


if [[$Changes == $true]]
then
    echo "Rebooting to apply changes"
    reboot
fi