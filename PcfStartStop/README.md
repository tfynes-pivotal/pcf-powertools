# pcf-powertools

pcf-start-stop.sh

Designed to run locally on a Pivotal Operations Manager host

SSH to OpsManager host and log into the bosh director then use script with following args as required

shutall
	Fast tear down of an entire foundation using vm deletion - this is the fastest was to get bosh to tear down a running foundation.

shut
	Fast tear down of the currently set deployment. Using this to rebuild ERT with IPSEC enabled / disabled

start
	Iterates all bosh deployments, downloads the manifest files to /tmp and 'bosh -n deploy' calls for each (as a back ground / queued request)



