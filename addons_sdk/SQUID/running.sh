#!/bin/bash
#
# This script returns 0 if service is running, 1 otherwise.
#

if ! pidof squid &> /dev/null ; then
	exit 1;
fi
exit 0;
