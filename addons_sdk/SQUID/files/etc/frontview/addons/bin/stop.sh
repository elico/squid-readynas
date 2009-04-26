#!/bin/bash
#
# This should contain necessary code to stop the service

start-stop-daemon --stop  --pidfile /var/run/SQUID.pid --signal KILL --quiet
