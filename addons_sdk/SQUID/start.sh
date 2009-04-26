#!/bin/bash

. /etc/default/services;

if [ "$SQUID_ALLOWED_HOSTS" == "" ] ; then {
	ALLOWED_HOSTS="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16";
} else {
	ALLOWED_HOSTS=$SQUID_ALLOWED_HOSTS;
} fi

sed "s#ALLOWED_HOSTS#${ALLOWED_HOSTS}#" /opt/squid/etc/squid.conf.tmpl > /opt/squid/etc/squid.conf;

if ! pidof squid &> /dev/null ; then
	/opt/squid/sbin/squid -D;
fi
