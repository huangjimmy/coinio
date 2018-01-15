#!/bin/bash

# Usage:
# Go into cmd loop: sudo ./cpsc.sh
# Run single cmd:  sudo ./cpsc.sh <cpsc paramers>

PREFIX="docker exec docker_cpsd_1 cpsc"
if [ -z $1 ] ; then
  while :
  do
    read -e -p "cpsc " cmd
    history -s "$cmd"
    $PREFIX $cmd
  done
else
  $PREFIX $@
fi
