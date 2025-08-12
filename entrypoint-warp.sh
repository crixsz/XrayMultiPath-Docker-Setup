#!/bin/bash

# start warp-svc in background
/bin/warp-svc &
WARP_SVC_PID=$!

# graceful shutdown
trap 'kill "$WARP_SVC_PID"; wait "$WARP_SVC_PID" 2>/dev/null || true' TERM INT EXIT

# wait until warp-cli can talk to the daemon
i=0
until warp-cli --version >/dev/null 2>&1; do
  sleep 0.2
  i=$((i+1))
  [ "$i" -gt 100 ] && echo "warp-svc not responding" >&2 && exit 1
done

# if a command is provided, run it; else keep container alive
if [ "$#" -gt 0 ]; then
  exec "$@"
else
  # Just let the script exit, and the CMD will take over
  exit 0
fi

# Start the WARP service
/usr/bin/warp-svc &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?