ForEachCma() {
  # Pulling in cp profile and ignore cpdir errors in lint as its not in the repo but will be on any checkpoint system
  # shellcheck source=/dev/null
  source "$CPDIR/tmp/.CPprofile.sh"
  local param1="$1"
  # run commands on all domains
  for DOMAIN in $(${MDSVERUTIL} AllCMAs); do
    echo "##############################################"
    echo "             Moving to: $DOMAIN"
    echo "##############################################"
    mdsenv "$DOMAIN"
    echo "##############################################"
    echo "        Running your command $param1"
    echo "##############################################"
    "$param1"
  done
}
