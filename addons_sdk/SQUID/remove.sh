#!/bin/bash

SERVICE=SQUID
CONF_FILES=""
PROG_FILES="/etc/frontview/apache/addons/SQUID.conf* \
            /etc/frontview/addons/*/SQUID \
			/opt/squid \
			/c/squid"

# Stop service from running
eval `awk -F'!!' "/^$SERVICE\!\!/ { print \\$5 }" /etc/frontview/addons/addons.conf`

# Remove program files
if ! [ "$1" = "-upgrade" ]; then
  if [ "$CONF_FILES" != "" ]; then
    for i in $CONF_FILES; do
      rm -rf $i &>/dev/null
    done
  fi
fi

if [ "$PROG_FILES" != "" ]; then
  for i in $PROG_FILES; do
    rm -rf $i
  done
fi

# Remove entry from services file
sed -i "/^$SERVICE/d" /etc/default/services

# Remove entry from addons.conf file
sed -i "/^$SERVICE\!\!/d" /etc/frontview/addons/addons.conf

# Reread modified service configuration files
killall -USR1 apache-ssl

# Now remove ourself
rm -f $0

exit 0
