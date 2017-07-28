#!/bin/bash

# Prototype PCF DIEGO SCALER USING OPSMGR API
# Tested on OM Host (uses uaac client)
# Pre-req add the 'jq' executable to the host and present on path (sudo apt-get update && sudo apt-get install jq)
#
# Now works when run as root - so it can be fitted into a crontab entry for automated scaling!
# 49 1 * * * sudo  /home/ubuntu/cellscaler.sh #Cells >/tmp/scaler.log 2>&1

if [ "$#" -ne 1 ]; then
    echo "Usage: cellscaler.sh <Desired # of DiegoCells> >/tmp/cellscaler.log 2>&1"
    exit 1
fi

export NEW_CELL_COUNT=$1
export OPSMGRHOST=<opsmanager host>
export OPSMANAGERUSER=<opsmanager user - e.g. admin>
export OPSMANAGERPASS=<opsmanager password>

export PATH=$PATH:/usr/local/bin

# LOG INTO OPSMANAGER
BUNDLE_GEMFILE=/home/tempest-web/tempest/web/vendor/uaac/Gemfile bundle exec uaac --skip-ssl-validation target https://$OPSMGRHOST/uaa
BUNDLE_GEMFILE=/home/tempest-web/tempest/web/vendor/uaac/Gemfile bundle exec uaac token owner get opsman $OPSMANAGERUSER -s "" -p "$OPSMANAGERPASS"
export access_token=`BUNDLE_GEMFILE=/home/tempest-web/tempest/web/vendor/uaac/Gemfile bundle exec uaac context | grep access_token | awk '{print $2}'`

# GET CF(ERT) DEPLOYMENT GUID
export cfguid=`curl -s -k -H "Authorization: Bearer $access_token" https://$OPSMGRHOST/api/v0/staged/products | jq -r -c '[ .[] | select( .type == "cf") ]' | jq -r .[].guid`

# GET DIEGO CELL GUID
export diego_cell_guid=`curl -s -k -H "Authorization: Bearer $access_token" https://$OPSMGRHOST/api/v0/staged/products/$cfguid/jobs | jq -r '.[] ' | jq -r -c '.[] | select(.name == "diego_cell")' | jq -r .guid`

# GET DIEGO CELL RESORUCE CONFIG
export diego_cell_resource_config=`curl -s -k -H "Authorization: Bearer $access_token" https://$OPSMGRHOST/api/v0/staged/products/$cfguid/jobs/$diego_cell_guid/resource_config`

# UPDATE DIEGO CELL RESOURCE CONFIG
export new_diego_cell_resource_config=`echo $diego_cell_resource_config | jq -r ".instances = $NEW_CELL_COUNT"`
curl -s -k -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" https://$OPSMGRHOST/api/v0/staged/products/$cfguid/jobs/$diego_cell_guid/resource_config -d "$new_diego_cell_resource_config"

# APPLYING CHANGES
echo "UPDATING TO $NEW_CELL_COUNT DIEGO CELLS IN FOUNDATION"
curl -s -k -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" https://$OPSMGRHOST/api/v0/installations -d '{ "deploy_products": "all", "ignore_warnings": true }'
echo "Ops Manager commanded to scale diego cell count to $NEW_CELL_COUNT"
