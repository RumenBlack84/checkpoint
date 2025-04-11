# This function can be installed with the following commands
# To install the function run these commands and then relogin to bash
# curl_cli -k https://raw.githubusercontent.com/RumenBlack84/checkpoint/refs/heads/main/Bash-Functions/Clear-IA-Cache.sh -o /etc/profile.d/Clear-IA-Cache.sh
# chmod +x /etc/profile.d/Clear-IA-Cache.sh
# dos2unix /etc/profile.d/Clear-IA-Cache.sh
Clear-IA-Cache() {
  fw tab -t pdp_sessions -t pdp_super_sessions -t pdp_encryption_keys -t pdp_whitelist -t pdp_timers -t pdp_expired_timers -t pdp_ip -t pdp_net_reg -t pdp_net_db -t pdp_cluster_stat -t pep_pdp_db -t pep_networks_to_pdp_db -t pep_net_reg -t pep_reported_network_masks_db -t pep_port_range_db -t pep_async_id_calls -t pep_client_db -t pep_identity_index -t pep_revoked_key_clients -t pep_src_mapping_db -t pep_log_completion -x -y
  fw6 tab -t pdp_sessions -t pdp_super_sessions -t pdp_encryption_keys -t pdp_whitelist -t pdp_timers -t pdp_expired_timers -t pdp_ip -t pdp_net_reg -t pdp_net_db -t pdp_cluster_stat -t pep_pdp_db -t pep_networks_to_pdp_db -t pep_net_reg -t pep_reported_network_masks_db -t pep_port_range_db -t pep_async_id_calls -t pep_client_db -t pep_identity_index -t pep_revoked_key_clients -t pep_src_mapping_db -t pep_log_completion -x -y
  fw kill pdpd
  fw kill pepd
  echo "# If no errors were reported than the IA tables were successfully cleared and the processes reset."
}
