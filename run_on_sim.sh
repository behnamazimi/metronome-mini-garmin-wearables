#!/bin/sh
# Use the SDK selected in Connect IQ SDK Manager (requires API 5.2.0+ for venu3)
SDK=$(cat ~/Library/Application\ Support/Garmin/ConnectIQ/current-sdk.cfg | tr -d '\n')

# Device to use for the simulator
# See https://developer.garmin.com/connect-iq/sdk-guides/supported-devices/ for supported devices
DEVICE=${1:-vivoactive4}

# Kill any lingering monkeydo from a previous run
pkill -f "monkeydo.*MetronomeMini" 2>/dev/null

# Build
"$SDK/bin/monkeyc" -d $DEVICE -f monkey.jungle -o bin/MetronomeMini.prg \
  -y ~/Library/Application\ Support/Garmin/ConnectIQ/developer_key.der || exit 1

# Launch simulator (no-op if already open on macOS)
open "$SDK/bin/ConnectIQ.app"

# monkeydo exits immediately on failure, stays alive on success — use that to detect readiness
for i in 1 2 3 4 5; do
  sleep 3
  "$SDK/bin/monkeydo" bin/MetronomeMini.prg $DEVICE &
  MONKEYDO_PID=$!
  sleep 1
  if kill -0 $MONKEYDO_PID 2>/dev/null; then
    disown $MONKEYDO_PID
    echo "App running in $DEVICE simulator (pid $MONKEYDO_PID)."
    exit 0
  fi
  echo "Simulator not ready, retrying... ($i/5)"
done

echo "Failed to connect to simulator after 5 attempts."
exit 1
