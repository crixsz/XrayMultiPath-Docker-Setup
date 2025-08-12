
#!/bin/bash

# Check if the WARP client is registered
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
    echo "WARP is not registered. Please run the following command to register:"
    echo "docker-compose run --rm warp warp-cli register"
    exit 1
fi

# Start the WARP service
/usr/bin/warp-svc &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
