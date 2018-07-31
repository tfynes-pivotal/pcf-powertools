#!/bin/bash

shopt -s expand_aliases
source ~/.profile

if [ "$#" -ne 6 ]
	then
		echo "Usage: SRJoin.sh Org1 Space1 ServiceRegistry1 Org2 Space2 ServiceRegistry2"
		exit 1
fi

org1=$1
space1=$2
sr1=$3
org2=$4
space2=$5
sr2=$6

#echo "$org1 $space1 $sr1 $org2 $space2 $sr2"

cf target -o $org1 -s $space1
eureka1id=$(cf service $sr1 | grep dashboard | rev | cut -d "/" -f1 | rev)
app1domain=$(cf service $sr1 | grep dashboard | awk -F[/:] '{print $5}' | cut -c 20-)
eureka1="https://eureka-$eureka1id$app1domain"
echo "eureka1 = $eureka1"

cf target -o $org2 -s $space2
eureka2id=$(cf service $sr2 | grep dashboard | rev | cut -d "/" -f1 | rev)
app2domain=$(cf service $sr2 | grep dashboard | awk -F[/:] '{print $5}' | cut -c 20-)
eureka2="https://eureka-$eureka2id$app2domain"
echo "eureka2 = $eureka2"

echo "Targetting Service Registry 1"
cf target -o $org1 -s $space1
echo "Peering Service Registry 2 into Service Registry 1"
echo "cf update-service $sr1 -c \"{ \"peers\": [ {\"uri\": \"$eureka2\"} ] }"""
cf update-service $sr1 -c "{ \"peers\": [ {\"uri\": \"$eureka2\"} ] }"


echo "Targetting Service Registry 2"
cf target -o $org2 -s $space2
echo "Peering Service Registry 1 into Service Registry 2"
echo "cf update-service $sr2 -c \"{ \"peers\": [ {\"uri\": \"$eureka1\"} ] }"""
cf update-service $sr2 -c "{ \"peers\": [ {\"uri\": \"$eureka1\"} ] }"
