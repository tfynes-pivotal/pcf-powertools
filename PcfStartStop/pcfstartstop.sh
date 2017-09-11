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
 
 deleteVMs() {
  bosh vm resurrection off
   for x in $jobVMs; do
      jobId=$(echo $x | awk -F "/" '{ print $1 }')
      instanceId=$(echo $x | awk -F "/" '{ print $2 }'| awk -F '(' '{ print $1 }')
      if [ -z $instanceId ]; then
        continue
      fi
      jobVMID=$(echo $x | awk -F ',' '{ print $2 }')
        echo Killing: $jobId
        bosh -n -N delete vm $jobVMID
    done
    echo "Kill VM tasks scheduled, execing 'watch bosh tasks --no-filter' to track progress"
    watch -n 10 'BUNDLE_GEMFILE=/home/tempest-web/tempest/web/vendor/bosh/Gemfile bundle exec bosh tasks --no-filter' 
 }
 
 if [ $1 == "shutall" ]; then
  jobVMs=$(bosh vms --details| awk -F '|' '{gsub(/ /, "", $0); print $2","$7 }')
  deleteVMs
 fi
 
 if [ $1 == "shut" ]; then
  jobVMs=$(bosh instances --details| awk -F '|' '{gsub(/ /, "", $0); print $2","$7 }')
  deleteVMs
 fi
 
 
 if [ $1 == "start" ]; then
  #bosh -n deploy
  #bosh vm resurrection on

	declare -a boshdeployments=()
	deployments=$(bosh deployments | awk -F '|' '{gsub(/ /, "", $0); print $2}')
	for x in $deployments; do
        	if [ -n $x ]; then
                	if [ "$x" != "Name" ]; then
                        	boshdeployments+=($x)
                	fi
        	fi
	done
	for x in ${boshdeployments[@]}; do
        	echo "BOSH Instancs for Deployment $x"
	 	rm -f /tmp/$x.yml	
		bosh download manifest $x /tmp/$x.yml
                uuid=$(bosh status --uuid)
                directoruuid="director_uuid: $uuid"
                if grep -q 'director_uuid' /tmp/$x.yml
                then
                  :
                else
                  sed -i "3i$directoruuid" /tmp/$x.yml
                fi
        	bosh -n -d /tmp/$x.yml deploy &
	done
	watch -n 10 'BUNDLE_GEMFILE=/home/tempest-web/tempest/web/vendor/bosh/Gemfile bundle exec bosh tasks --no-filter'
 fi
