#!/bin/bash
sudo -u tempest-web SECRET_KEY_BASE=X /home/tempest-web/tempest/web/scripts/decrypt /var/tempest/workspaces/default/actual-installation.yml  /tmp/ai.yml 2>/dev/null
acpw=`cat /tmp/ai.yml | grep -m 1 -A 3 "identifier: admin_client_credentials" | grep password | awk '{print $2}'`
echo "$acpw"
#sudo rm -f /tmp/ai.yml

