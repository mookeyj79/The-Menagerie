#!/bin/sh
set -e

for f in tailscale_authkey tailscale_routes tailscale_hostname; do
  [ -f "/run/secrets/$f" ] || { echo "Missing secret: $f"; exit 1; }
done

STATE_DIR="/var/lib/tailscale"

AUTHKEY="$(tr -d '\r\n' </run/secrets/tailscale_authkey)"
ROUTES="$(tr -d '\r\n' </run/secrets/tailscale_routes)"
HNAME="$(tr -d '\r\n' </run/secrets/tailscale_hostname)"

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

# Start tailscaled with scoped state dir
TS_STATE_DIR="$STATE_DIR" tailscaled &

# Wait for daemon socket
while [ ! -S /var/run/tailscale/tailscaled.sock ]; do
  sleep 0.5
done

# Check if already authenticated
if tailscale status --json | grep -q '"BackendState": "Running"'; then
  echo "Reseting Tailscale Connection..."
  tailscale up --reset \
    --hostname="$HNAME" \
    --advertise-routes="$ROUTES" \
    --snat-subnet-routes
else
  echo "Authenticating Tailscale…"
  tailscale up \
    --authkey="$AUTHKEY" \
    --hostname="$HNAME" \
    --advertise-routes="$ROUTES" \
    --snat-subnet-routes
fi

# Wipe secrets from shell memory
unset AUTHKEY ROUTES HNAME

# Keep container alive
wait
