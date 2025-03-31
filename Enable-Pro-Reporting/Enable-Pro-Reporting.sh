#!/bin/bash
# This will enable the required telemetry to Checkpoint to enable pro reporting.
# More information is available in this SK https://support.checkpoint.com/results/sk/sk155212
# Ensure you add a user with Pro Contact Permissions to your usercenter to recieve information
# This person will also be in the contact list for any Service requests created from the telemtry

# Sign in to User Center.
# From the top, click Support / Services.
# In the left section Support Center, click Check Point PRO Report.
# In the applicable account, on the right side, click Manage Contacts.
# Select the applicable person and click Add PRO Contact Permission.
# Close the Account PRO Contacts popup window.

# Please note this is still useful to do even if you do not subscribe to to Pro Reports
# This information is available to Technical Servers when working on cases.
# An internal link will be provided in the documentation of this script where TAC
# can view the telemetry and any reported errors.

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
mgmt_cli -r true install-database targets.1 "$target"
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
    mgmt_cli -r true -d "$DOMAIN_NAME" install-database targets.1 "$target"
    done
done
echo "##############################################" 
echo "Ensure you run this script on your other MDS too!"
echo "##############################################" 
fi

echo "##############################################" 
echo "Now that you are sending Checkpoint the Telemetry,"
echo "ensure that you set a Pro Contact for your account"
echo "as per sk155212 to be notified based on this info."
echo "##############################################" 

