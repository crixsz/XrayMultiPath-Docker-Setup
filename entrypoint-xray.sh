#!/bin/bash

# Wait for the WARP service to be ready
while [ ! -S /var/run/warp.sock ]; do
    echo "Waiting for WARP service..."
    sleep 1
done

# Start Nginx in the background
nginx -g 'daemon off;' &

# Start the Xray services
# Note: Using systemctl directly doesn't work well in basic Docker containers.
# We run them directly as background processes instead.
/usr/local/bin/xray -config /usr/local/etc/xray/none.json &
/usr/local/bin/xray -config /usr/local/etc/xray/config.json &
/usr/local/bin/xray -config /usr/local/etc/xray/direct.json &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?