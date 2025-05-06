#!/bin/bash

# Query names from Postgres
readarray -t sk126872nets < <(
  psql_client cpm postgres -Atc "
    select name 
    from dleobjectderef_data 
    where fwset like '%:cdm_auto_calculated (true)%' 
    and dlesession = 0 
    and not deleted
  "
)

# Directly loop over names and process
for net in "${sk126872nets[@]}"; do
  uid=$(mgmt_cli -r true show network name "$net" details-level uid --format json | jq -r '.uid')

  # Only attempt set if we got a valid UID
  if [[ -n "$uid" && "$uid" != "null" ]]; then
    echo "Setting cdmAutoCalculated on $net (UID: $uid)"
    mgmt_cli -r true set-generic-object uid "$uid" cdmAutoCalculated true
  else
    echo "Warning: No UID found for $net, skipping."
  fi
done
