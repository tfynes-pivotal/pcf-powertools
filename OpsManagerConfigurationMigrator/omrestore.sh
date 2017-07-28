#!/bin/bash

# Restore a local file OpsManager backup (installation.zip) file to a brand new OpsManager deployment. 
# Useful when updating OpsManager as it negates the need to copy the installation.zip to another network

export OPSMGRHOST=<opsmanager host>
export OPSMANAGERUSER=<opsmanager user>
export OPSMANAGERPASS=<pass>

# uaac cmd is an alias set in .profile of ops manager user
shopt -s expand_aliases
source ~/.profile

echo "IMPORTING OPSMAGNAGER SETTINGS"
curl -k "https://$OPSMGRHOST/api/v0/installation_asset_collection" -X POST -F 'installation[file]=@installation.zip' -F "passphrase=$OPSMANAGERPASS"

echo "IMPORT COMPLETE - Browse to new OpsMgr host to complete update"



# OPTIONAL - RUN 'APPLY CHANGES' from script - likely to complain if stemcells are missing from new OpsMgr.
# LOG INTO OPSMANAGER
#uaac --skip-ssl-validation target https://$OPSMGRHOST/uaa
#uaac token owner get opsman $OPSMANAGERUSER -s "" -p "$OPSMANAGERPASS"
#export access_token=`uaac context | grep access_token | awk '{print $2}'`
# TRIGGER DIRECTOR UPDATE
#curl -k "https://$OPSMGRHOST/api/v0/installations" -X POST -H "Authorization: Bearer $access_token" -H "Content-Type: application/json" -d '{ "deploy_products": "none", "ignore_warnings": true }'
