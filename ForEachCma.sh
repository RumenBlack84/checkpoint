#!/bin/bash
# To do:
# Turn into a function to run commands against all CMA

# Pulling in cp profile and ignore cpdir errors in lint as its not in the repo but will be on any checkpoint system
# shellcheck source=/dev/null
source "$CPDIR/tmp/.CPprofile.sh"

# run commands on all domains
for DOMAIN in $(${MDSVERUTIL} AllCMAs); do 
    echo "##############################################"
    echo "             Moving to: $DOMAIN"
    echo "##############################################"
    mdsenv "$DOMAIN"
    echo "##############################################" 
    echo "        something something command"
    echo "##############################################" 
done
