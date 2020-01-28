#!/bin/bash
sudo -u tempest-web SECRET_KEY_BASE=X /home/tempest-web/tempest/web/scripts/decrypt /var/tempest/workspaces/default/actual-installation.yml  /tmp/ai.yml 2>/dev/null
cat /tmp/ai.yml | grep -m 1 -A 1 "identity: director" | grep password | awk '{print $2}'
#sudo rm -f /tmp/ai.yml
