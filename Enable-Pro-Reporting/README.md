# Enabling Pro Reporting as per sk155212
This script is meant to help automate the process of enabling the required information to be sent to checkpoint to enable pro reporting.
For a single Management server this process is quite easy and straight forward. However if you need to enable it an MDS environment with many domains it can be a daunting task.
If running in an MDS environment ensure you run the script on all MDS Servers to ensure all active CMAs have the required telemetry set.

The script on should be run on every MDS Server or Active SMS in the environment by copying this command block into an expert mode command line on each system.

# Runing the script
```bash
# Ensure the tmp dir exists \
mkdir -p /var/log/tmp/ ; \
# Pull the script from github and save it to /var/log/tmp \
curl_cli -k "https://raw.githubusercontent.com/RumenBlack84/checkpoint/refs/heads/main/Enable-Pro-Reporting/Enable-Pro-Reporting.sh" -o /var/log/tmp/Enable-Pro-Reporting.sh ; \
# Ensure the script can be executed \
chmod +x /var/log/tmp/Enable-Pro-Reporting.sh ; \
# Ensure the script has the right formatting \
dos2unix /var/log/tmp/Enable-Pro-Reporting.sh ; \
# Actually run the script \
/var/log/tmp/Enable-Pro-Reporting.sh ; \
# Cleanup the script once we are done \
rm -v /var/log/tmp/Enable-Pro-Reporting.sh ;
```
# The Script will take the following actions;
- It will first ensure the system is a Management server of some type, if it is not the script will exit.
- It will then determine if the Management server is currently the active management server so that it can make changes. If it is not the script will exit.
- If the script is an active management server the script will enable the required telemetry and then install database to all management and log servers in the environment.
- If the server is an MDS server it will start a loop to enable the required telemetry in each Domain on the server and then install database to all CMAs and CLMs in the domain.
  - If the CMA it attempts this process on is not the active CMA it will fail and discard changes. This is to be expected as only the active CMA has the ability to make changes.
  - This is why the process needs to be repeated on All MDS Servers in the environment with active CMAs present.
- Once completed the script will remind you to create a Pro Contact for your account as per sk155212
- I encourage everyone to read over any script before they run them.
