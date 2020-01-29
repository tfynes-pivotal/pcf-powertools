#!/bin/bash

sysdomain1=$1
sysdomain2=$2
as1=$3

uaac target uaa.$sysdomain1
uaac token client get admin -s $as1
uaac client get apps_manager_js
uaac client update apps_manager_js --redirect_uri "https://uaa.$sysdomain1/**,https://uaa.$sysdomain2/**"
uaac client get apps_manager_js
