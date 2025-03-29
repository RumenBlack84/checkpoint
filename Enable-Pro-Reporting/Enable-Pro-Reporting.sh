#!/bin/bash
# not yet finished more documentation and logic required

# Need to install-database to script as well.
# However I first need to fetch a list of targets the below should create an array of mgmt servers, log servers etc.
# for mds this should be filtered down by domain by adding -d to mgmt_cli call.
# readarray -t TARGETS < <(
#  mgmt_cli -r true show gateways-and-servers limit 500 --format json | \
#  jq -r '.objects[] | select(.type == "checkpoint-host") | .name'
#)


is_mgmt=`cpprod_util FwIsFirewallMgmt`
if [ ${is_mgmt} = 0 ]; then
echo "##############################################"  
echo "# This is not a management Server! #"
echo "# Please run me on your active management server #"
echo "##############################################" 
exit 
fi

is_mds=`cpprod_util CPPROD_IsConfigured PROVIDER-1`

is_active_mgmt=`cpprod_util FwIsActiveManagement`

# exit if not active SMS
if [ ${is_active_mgmt} = 0 ] && [ ${is_mds} = 0 ]; then
echo "##############################################"  
echo "# This is not the active management Server! #"
echo "# Please run me on your active management server #"
echo "##############################################" 
exit 
fi

if [ ${is_active_mgmt} = 1 ] && [ ${is_mds} = 0 ]; then
echo "##############################################" 
echo "Enabling Pro Reporting on active SMS"
echo "##############################################" 
mgmt_cli -r true set global-properties data-access-control.auto-download-important-data true data-access-control.auto-download-sw-updates-and-new-features true data-access-control.send-anonymous-info true data-access-control.share-sensitive-info true
# Let's get all the install database targets
readarray -t TARGETS < <(
  mgmt_cli -r true show gateways-and-servers limit 500 --format json | \
  jq -r '.objects[] | select(.type == "checkpoint-host") | .name'
)
# Install database to the targets fetched above
for target in "${TARGETS[@]}"; do
"mgmt_cli -r true install-database targets.1 $target"
done
fi

if [ ${is_mds} = 1 ]; then
# Initialize an empty array
ALL_DOMAINS=()

# Run the command and extract the 'objects' list into a Bash array
mapfile -t ALL_DOMAINS < <(mgmt_cli -r true show domains details-level uid limit 500 --format json | jq -r '.objects[]')

# Iterate over each element in the array
for entry in "${ALL_DOMAINS[@]}"; do
    # Crafting command to find domain name
    DOMAIN_NAME=$(mgmt_cli -r true show domain uid "$entry" --format json | jq -r '.name')
    echo "##############################################"  
    echo "# $entry belongs to the $DOMAIN_NAME domain. #"
    echo "##############################################" 
    echo "##############################################" 
    echo "Enabling Pro Reporting on $DOMAIN_NAME domain"
    echo "##############################################" 
    mgmt_cli -r true -d "$DOMAIN_NAME" set global-properties data-access-control.auto-download-important-data true data-access-control.auto-download-sw-updates-and-new-features true data-access-control.send-anonymous-info true data-access-control.share-sensitive-info true
    readarray -t TARGETS < <(
    mgmt_cli -r true -d "$DOMAIN_NAME" show gateways-and-servers limit 500 --format json | \
    jq -r '.objects[] | select(.type == "checkpoint-host") | .name'
    )
    # Install database to the targets fetched above
    for target in "${TARGETS[@]}"; do
    "mgmt_cli -r true -d "$DOMAIN_NAME" install-database targets.1 $target"
    done
done
echo "##############################################" 
echo "Ensure you run this script on your other MDS too!"
echo "##############################################" 
fi
