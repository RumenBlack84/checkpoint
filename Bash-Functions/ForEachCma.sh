ForEachCma() {
  # Pulling in cp profile and ignore cpdir errors in lint as its not in the repo but will be on any checkpoint system
  # shellcheck source=/dev/null
  source "$CPDIR/tmp/.CPprofile.sh"
  local param1="$1"
  if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
    echo "Usage: ForEachCma <CommandToRun>"
    echo
    echo "Runs your specified command against all CMAs on the MDS"
    echo
    echo "Example:"
    # disalbing SC2016 for these lines as I literally want these strings
    # shellcheck disable=SC2016
    echo '  ForEachCMAmy_function "echo $FWDIR"'
    # shellcheck disable=SC2016
    echo 'This will print the $FWDIR variable on each CMA'
    return 0
  fi
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
