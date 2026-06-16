#!/bin/sh
# The Ultimate App-Level Check: 
# If wget successfully downloads the "OK" text, the process AND port are guaranteed working.
if wget -q -O - http://localhost:8080/health | grep "OK" > /dev/null; then
    exit 0
else
    exit 1
fi
