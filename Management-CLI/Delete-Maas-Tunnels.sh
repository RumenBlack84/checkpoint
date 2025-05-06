#!/bin/bash
# Remove Maas for single gateways
readarray -t TARGETS < <(
  mgmt_cli -r true show gateways-and-servers limit 500 --format json |
    jq -r '.objects[] | select(.type == "simple-gateway") | .uid'
)

for target in "${TARGETS[@]}"; do
  mgmt_cli -r true delete interface name maas_tunnel gateway-uid "$target"
done

# Remove Maas for clusters, running command twice as it presents in two seperate interfaces in most cases
readarray -t TARGETS < <(
  mgmt_cli -r true show gateways-and-servers limit 500 --format json |
    jq -r '.objects[] | select(.type == "simple-cluster") | .uid'
)

for target in "${TARGETS[@]}"; do
  mgmt_cli -r true delete interface name maas_tunnel gateway-uid "$target"
  mgmt_cli -r true delete interface name maas_tunnel gateway-uid "$target"
done
