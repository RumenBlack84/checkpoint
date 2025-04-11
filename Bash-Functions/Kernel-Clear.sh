#!/bin/bash
# This function is meant to help prevent disk space from filling while running a KdebugPath
# Provide the path to the kernel debug file in a first arguement, it must be located in /var/log/
# Usage: Kernel-Clear /var/log/tmp/kdebug.txt
# This function can be invoked withth a watch command to run contineously
# This will run every 15 seconds.
# watch -n 15 "Kernel-Clear /var/log/tmp/kdebug.txt"
# This function can be installed with the following commands
# To install the function run these commands and then relogin to bash
# curl_cli -k https://raw.githubusercontent.com/RumenBlack84/checkpoint/refs/heads/main/Bash-Functions/Kernel-Clear.sh -o /etc/profile.d/Kernel-Clear.sh
# chmod +x /etc/profile.d/Kernel-Clear.sh
# dos2unix /etc/profile.d/Kernel-Clear.sh
Kernel-Clear() {
  local KdebugPath="$1"

  if [[ -z "$KdebugPath" ]]; then
    echo "Error: Path to Kdebug path must be provided as an arguement!"
    exit 1
  fi

  if [[ "$KdebugPath" != /var/log/* ]]; then
    echo "Error: Path must start with /var/log/"
    exit 1
  fi

  # Log file location
  LOG_FILE="/home/admin/Kernel-Clear.log"

  # Get the percentage of space used in /var/log
  USAGE=$(df /var/log | awk 'NR==2 {print $5}' | sed 's/%//')

  # Define the threshold
  THRESHOLD=90

  # Log timestamp
  echo "$(date) - Checking /var/log usage..." | tee -a "$LOG_FILE"

  # Check if usage exceeds threshold
  if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "$(date) - Warning: /var/log usage is above ${THRESHOLD}% (${USAGE}%)" | tee -a "$LOG_FILE"

    # Replace with the command you want to run
    echo "$(date) - Clearing Kernel Debug File..." | tee -a "$LOG_FILE"
    echo "" >"$KdebugPath"
  else
    echo "$(date) - /var/log usage is at ${USAGE}%, below the threshold of ${THRESHOLD}%" | tee -a "$LOG_FILE"
  fi
}
