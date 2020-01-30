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
  deployments=$(/home/ubuntu/execbosh.sh deployments --column=Name)
  #jobVMs=$(/home/ubuntu/execbosh.sh vms --column="VM CID" --json | jq --raw-output .Tables[].Rows[].vm_cid)
  for thisDeployment in $deployments; do
    jobVMs=$(/home/ubuntu/execbosh.sh -d $thisDeployment vms --json | jq --raw-output .Tables[].Rows[].vm_cid)
    #jobVMs=$(/home/ubuntu/execbosh.sh -d $thisDeployment vms --column="VM CID")
    for thisVM in $jobVMs; do
      echo "DELETING $thisDeployment : $thisVM"
      $(/home/ubuntu/execbosh.sh -n -d $thisDeployment delete-vm $thisVM) &
    done
  done
 fi

 if [ $1 == "shut" ]; then
  jobVMs=$(/home/ubuntu/execbosh.sh instances --details| awk -F '|' '{gsub(/ /, "", $0); print $2","$7 }')
  deleteVMs
 fi


 if [ $1 == "start" ]; then
  #/home/ubuntu/execbosh.sh -n deploy
  #/home/ubuntu/execbosh.sh vm resurrection on

	declare -a boshdeployments=()
	deployments=$(/home/ubuntu/execbosh.sh deployments --json | jq --raw-output .Tables[].Rows[].name)
	for thisDeployment in $deployments; do
          if [[ $thisDeployment == "cf-"* ]]; then
             /home/ubuntu/execbosh.sh  -d $thisDeployment manifest > /tmp/$thisDeployment.yml
             nohup bash -c "/home/ubuntu/execbosh.sh -n -d $thisDeployment deploy /tmp/$thisDeployment.yml" &
          fi
        done 
        #sleep 15m
	for thisDeployment in $deployments; do
          /home/ubuntu/execbosh.sh -n -d $thisDeployment manifest > /tmp/$thisDeployment.yml
          nohup bash -c  "sleep 15m ; /home/ubuntu/execbosh.sh -n -d $thisDeployment -n deploy /tmp/$thisDeployment.yml"  &
	done
#	watch -n 10 '/home/ubuntu/execbosh.sh tasks --no-filter'
 fi
