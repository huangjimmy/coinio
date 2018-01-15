#!/bin/sh
cd /opt/cps/bin

if [ -f '/opt/cps/bin/data-dir/config.ini' ]; then
    echo
  else
    cp /config.ini /opt/cps/bin/data-dir
fi

if [ -f '/opt/cps/bin/data-dir/genesis.json' ]; then
    echo
  else
    cp /genesis.json /opt/cps/bin/data-dir
fi

if [ -d '/opt/cps/bin/data-dir/contracts' ]; then
    echo
  else
    cp -r /contracts /opt/cps/bin/data-dir
fi

exec /opt/cps/bin/cpsd $@
