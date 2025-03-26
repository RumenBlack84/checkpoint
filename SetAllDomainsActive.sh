#!/bin/bash
# This script will set all Domains on the MDS it is run on as the Active Member

# Array to put domains to start -m starts global

# Initialize an empty array
ALL_DOMAINS=()

# Run the command and extract the 'objects' list into a Bash array
mapfile -t ALL_DOMAINS < <(mgmt_cli -r true show domains details-level uid limit 500 --format json | jq -r '.objects[]')

echo "##############################################"
echo "#           Starting: Global Domain.         #"
echo "##############################################"

# just always start global level no consideration needed.
mdsstart -m

# Iterate over each element in the array
for entry in "${ALL_DOMAINS[@]}"; do
    echo "##############################################"
    echo "#             Starting: $entry.              #"
    echo "##############################################"
    # mdsstart_customer "$entry"
    # sleep 5
    # Use double quotes to allow variable expansion
    echo "##############################################"
    echo  "#  Crafting command to find Domain Name.     #"
    echo "##############################################"
    DOMAIN_NAME=$(mgmt_cli -r true show domain uid "$entry" --format json | jq -r '.name')
    echo "##############################################"  
    echo "# $entry belongs to the $DOMAIN_NAME domain. #"
    echo "##############################################" 
    echo "##############################################" 
    echo "Setting $DOMAIN_NAME active on this member"
    echo "##############################################" 
    mgmt_cli -r true -d "$DOMAIN_NAME" set ha-state new-state active
done
