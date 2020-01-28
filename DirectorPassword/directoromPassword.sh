#!/bin/bash
sudo -u tempest-web SECRET_KEY_BASE=X /home/tempest-web/tempest/web/scripts/decrypt /var/tempest/workspaces/default/actual-installation.yml  /tmp/ai.yml 2>/dev/null
ompw=`cat /tmp/ai.yml | grep -m 1 -A 1 "identity: ops_manager" | grep password | awk '{print $2}'`
#echo "OMPW = $ompw"

bip=`cat /tmp/ai.yml | grep -m 1 -A 1 "allocated_director_ips" | grep '-' | awk '{print $2}' `
#echo "BIP = $bip"

export BOSH_CLIENT=ops_manager 
export BOSH_CLIENT_SECRET=$ompw 
export BOSH_CA_CERT=/var/tempest/workspaces/default/root_ca_certificate 
export BOSH_ENVIRONMENT=$bip

if  [[ $(grep -L "BOSH_" ~/.bashrc) ]]; then 
  echo "export BOSH_CLIENT=ops_manager" >> ~/.bashrc 
  echo "export BOSH_CLIENT_SECRET=$ompw" >> ~/.bashrc
  echo "export BOSH_CA_CERT=/var/tempest/workspaces/default/root_ca_certificate" >> ~/.bashrc
  echo "export BOSH_ENVIRONMENT=$bip" >> ~/.bashrc
else
  echo Found BOSH ENVs in bashrc - not changing
fi

echo "BOSH_CLIENT=ops_manager BOSH_CLIENT_SECRET=$ompw BOSH_CA_CERT=/var/tempest/workspaces/default/root_ca_certificate BOSH_ENVIRONMENT=$bip bosh \$*" > /home/ubuntu/execbosh.sh
chmod +x /home/ubuntu/execbosh.sh

if [[ $(grep -L "bashrc" ~/.profile) ]]; then
  sudo chmod go+w ~/.profile
  echo "source ~/.bashrc" >> ~/.profile
  sudo chmod go-w ~/.profile
  . ~/.profile
else
  echo Found source .bashrc found in .profile - not changing
fi

sudo rm -f /tmp/ai.yml

