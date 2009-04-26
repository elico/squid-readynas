#!/bin/bash
#
# This should contain necessary code to start the service

start-stop-daemon -S -b -m --pidfile /var/run/SQUID.pid -q -x /etc/frontview/addons/bin/SQUID/SQUID_service
