#!/usr/bin/env bash

# === Configuration ===
NOTIFY_CMD="/usr/local/bin/notify-me"
HOST="$(hostname)"
LASTRUN_FILE="/var/log/unattended-upgrades/last-notified"

# Determine log file based on OS
if [[ -f /var/log/unattended-upgrades/unattended-upgrades.log ]]; then
    LOGFILE="/var/log/unattended-upgrades/unattended-upgrades.log"
elif [[ -f /var/log/dnf.rpm.log ]]; then
    LOGFILE="/var/log/dnf.rpm.log"
else
    echo "No recognized log file found. Exiting."
    exit 1
fi

# === Setup ===
mkdir -p "$(dirname "$LASTRUN_FILE")"
touch "$LASTRUN_FILE"

LASTRUN=$(cat "$LASTRUN_FILE")

# Extract new lines since last notification
NEW_LINES=$(awk -v last="$LASTRUN" '$0 > last' "$LOGFILE")

# Parse lines based on system type
if [[ "$LOGFILE" == *unattended-upgrades* ]]; then
    UPGRADED=$(echo "$NEW_LINES" | grep -i "Packages that will be upgraded")
    REBOOT_REQUIRED=$(echo "$NEW_LINES" | grep -i "system reboot required")
    ERRORS=$(echo "$NEW_LINES" | grep -Ei "ERROR|FAILED|dpkg returned an error")
else
    UPGRADED=$(echo "$NEW_LINES" | grep -i "Upgraded:")
    REBOOT_REQUIRED=$(echo "$NEW_LINES" | grep -i "Needs-restarting")
    ERRORS=$(echo "$NEW_LINES" | grep -Ei "error|fail")
fi

# Send notification if updates occurred or errors present
if [[ -n "$UPGRADED" || -n "$REBOOT_REQUIRED" || -n "$ERRORS" ]]; then
    MESSAGE="Host: $HOST\n\n"

    [[ -n "$UPGRADED" ]] && MESSAGE+="Packages upgraded:\n$UPGRADED\n\n"
    [[ -n "$REBOOT_REQUIRED" ]] && MESSAGE+="Reboot required.\n\n"
    [[ -n "$ERRORS" ]] && MESSAGE+="Errors:\n$ERRORS\n\n"

    echo -e "$MESSAGE" | $NOTIFY_CMD
fi

# Save last processed timestamp
tail -n 1 "$LOGFILE" > "$LASTRUN_FILE"
