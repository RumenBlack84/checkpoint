# Forked from https://github.com/billygr/CheckPoint/blob/master/sk83520.sh
# In order to better maintain and implement
# sk83520 connectivity check
# Checkmates URL where this originally appeared
# https://community.checkpoint.com/t5/Security-Gateways/sk83520-how-to-check-connectivity-to-CP/m-p/31874/highlight/true#M2558
# Run on the gw/mgmt curl_cli -k  https://raw.githubusercontent.com/RumenBlack84/checkpoint/refs/heads/main/sk83520.sh > sk83520.sh
# chmod +x sk83520.sh
# ./sk83520.sh
# shellcheck source=/dev/null
Check-Update-Status() {
  source "$CPDIR/tmp/.CPprofile.sh"
  local ProxyUrl="$1"

  if [[ -z "$ProxyUrl" ]]; then
    echo "##############################################################################################################"
    echo "                          No ProxyUrl provided, continuing without setting a proxy."
    echo "##############################################################################################################"
    # The desire here is to have this as a literal string to use later so disabling sc2016 for these lines
    # shellcheck disable=SC2016
    status_cmd='curl_cli --max-time 5 -k --head "$1" 2>/dev/null | grep HTTP | awk '"'"'{print $2}'"'"''
  else
    echo "##############################################################################################################"
    echo "             ProxyUrl Provded: $ProxyUrl setting this to use for connectivty checks."
    echo "##############################################################################################################"
    # shellcheck disable=SC2016
    status_cmd='curl_cli --max-time 5 -k --proxy "$ProxyUrl" --head "$1" 2>/dev/null | grep HTTP | awk '"'"'{print $2}'"'"''
  fi

  check_url() {
    result=" [ ERROR ]"
    name="$2 "
    while [ ${#name} -lt 74 ]; do name="$name."; done
    echo -en "$name "
    status_code=$(eval "$status_cmd")
    case "$status_code" in
    # Basically if it connects in anyway I'm happy, a lot of these require api calls and
    # formatting to get proper 200 codes
    1?? | 2?? | 3?? | 400 | 403 | 405 | 504)
      result="[ OK ]"
      ;;
    *)
      result="[ FAIL ] - Got HTTP ${status_code}"
      ;;
    esac
    echo "${result}"
  }

  echo "##############################################################################################################"
  echo "sk83520 How to verify that Security Gateway and/or Security Management Server can access Check Point servers"
  echo "##############################################################################################################"
  check_url 'http://cws.checkpoint.com/APPI/SystemStatus/type/short' 'Social Media Widget Detection'
  check_url 'http://cws.checkpoint.com/URLF/SystemStatus/type/short' 'URL Filtering Cloud Categorization'
  check_url 'http://cws.checkpoint.com/AntiVirus/SystemStatus/type/short' 'Virus Detection'
  check_url 'http://cws.checkpoint.com/Malware/SystemStatus/type/short' 'Bot Detection'
  check_url 'https://updates.checkpoint.com/WebService/Monitor' 'IPS Updates'
  check_url 'http://crl.godaddy.com/gdroot.crl' 'CRL check godaddy Update Service used for revocation'
  check_url 'http://crl.globalsign.net/root.crl' 'CRL check globalsign CRL that updates service certificate uses'
  check_url 'http://dl3.checkpoint.com' 'Download Service Updates'
  check_url 'https://usercenter.checkpoint.com/usercenter/services/ProductCoverageService' 'Contract Entitlement'
  check_url 'https://usercenter.checkpoint.com/usercenter/services/BladesManagerService' 'Software Blades Manager Service'
  check_url 'http://resolver1.chkp.ctmail.com' 'Suspicious Mail Outbreaks'
  check_url 'http://download.ctmail.com' 'Anti-Spam'
  check_url 'https://te.checkpoint.com/tecloud/Ping' 'Threat Emulation'
  check_url 'http://avupdates.checkpoint.com/UrlList.txt' 'Traditional Anti-Virus, Legacy URL Filtering'
  check_url 'http://sigcheck.checkpoint.com/Siglist2.txt' 'Download of signature updates for Traditional Anti-Virus, etc'
  check_url 'http://secureupdates.checkpoint.com/IP-list/100k.txt' 'Manage Security Gateways'
  check_url 'https://sc1.checkpoint.com/sc/images/checkmark.gif' 'Download of icons and screenshots from Check Point media storage servers'
  check_url 'https://sc1.checkpoint.com/za/images/facetime/large_png/60342479_lrg.png' 'Download of icons and screenshots from Check Point media storage servers'
  check_url 'https://sc1.checkpoint.com/za/images/facetime/large_png/60096017_lrg.png' 'Download of icons and screenshots from Check Point media storage servers'
  check_url 'https://push.checkpoint.com/push/ping' 'Push Notifications'
  check_url 'http://downloads.checkpoint.com' 'Download of Endpoint Compliance Updates'
  check_url 'http://productservices.checkpoint.com' 'Entitlement/Licensing Updates'
}
