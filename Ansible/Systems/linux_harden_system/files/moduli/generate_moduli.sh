#!/usr/bin/env bash
set -e

FLAG="/opt/scripts/hardening/ssh/moduli.generated"

if [ -f "$FLAG" ]; then
    echo "Moduli generation already completed."
    exit 0
fi

echo "Generating moduli candidates..."
ssh-keygen -M generate -O bits=4096 /tmp/moduli-4096.candidates
ssh-keygen -M screen -f /tmp/moduli-4096.candidates /tmp/moduli-4096
awk '$5 >= 3071' /tmp/moduli-4096 > /tmp/moduli-4096.safe

mv /tmp/moduli-4096.safe /etc/ssh/moduli
touch "$FLAG"

rm -f /tmp/moduli-4096 /tmp/moduli-4096.candidates

if [ -f "$SERVICE" ]; then
    echo "Disabling and removing systemd service..."
    systemctl disable --now generate-moduli.service
    systemctl daemon-reexec
    systemctl daemon-reload
fi
