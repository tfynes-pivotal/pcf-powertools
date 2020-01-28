#!/bin/bash


shopt -s expand_aliases
source ~/.profile


 # Deletes BOSH vms with ruthless abandon

 if [[ ($1 == "shut") || ($1 == "start" ) || ($1 == "shutall") ]]
         then
                 echo "Running PCF $1 Process (warning: this toggles director resurrection off/on!)..."
         else
                 echo "Usage: $0 [shut|start|shutall]"
                 exit 1
 fi

 if [ $1 == "shutall" ]; then
  deployments=$(bosh -e pcf deployments --column=Name)
  #jobVMs=$(bosh -e pcf vms --column="VM CID" --json | jq --raw-output .Tables[].Rows[].vm_cid)
  for thisDeployment in $deployments; do
    jobVMs=$(bosh -e pcf -d $thisDeployment vms --column="VM CID")
    for thisVM in $jobVMs; do
      echo "DELETING $thisDeployment : $thisVM"
      bosh -e pcf -n -d $thisDeployment delete-vm $thisVM &
    done
  done
 fi

 if [ $1 == "shut" ]; then
  jobVMs=$(bosh instances --details| awk -F '|' '{gsub(/ /, "", $0); print $2","$7 }')
  deleteVMs
 fi


 if [ $1 == "start" ]; then
  #bosh -n deploy
  #bosh vm resurrection on

	declare -a boshdeployments=()
	deployments=$(bosh -e pcf deployments --json | jq --raw-output .Tables[].Rows[].name)
	for thisDeployment in $deployments; do
          if [[ $thisDeployment == "cf-"* ]]; then
             bosh -e pcf -d $thisDeployment manifest > /tmp/$thisDeployment.yml
             bosh -e pcf -d $thisDeployment -n deploy /tmp/$thisDeployment.yml &
          fi
        done 
        sleep 10m
	for thisDeployment in $deployments; do
          bosh -e pcf -d $thisDeployment manifest > /tmp/$thisDeployment.yml
          bosh -e pcf -d $thisDeployment -n deploy /tmp/$thisDeployment.yml &
	done
	watch -n 10 'bosh -e pcf tasks --no-filter'
 fi
