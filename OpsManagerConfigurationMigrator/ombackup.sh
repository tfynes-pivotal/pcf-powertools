#!/bin/bash

# Export the OpsManager settings (installation.zip) to local filesystem
# Use in conjunction with omrestore.sh to migrate settings to updated OpsManager

export OPSMGRHOST=<opsmanager host>
export OPSMANAGERUSER=<opsmanager user>
export OPSMANAGERPASS=<opsmanager pass>

# uaac cmd is an alias set in .profile of ops manager user
shopt -s expand_aliases
source ~/.profile

# LOG INTO OPSMANAGER
uaac --skip-ssl-validation target https://$OPSMGRHOST/uaa
uaac token owner get opsman $OPSMANAGERUSER -s "" -p "$OPSMANAGERPASS"
export access_token=`uaac context | grep access_token | awk '{print $2}'`

echo "EXPORTING OPSMAGNAGER SETTINGS"
curl -k -s "https://$OPSMGRHOST/api/v0/installation_asset_collection" -X GET -H "Authorization: Bearer $access_token" -o "installation.zip"
