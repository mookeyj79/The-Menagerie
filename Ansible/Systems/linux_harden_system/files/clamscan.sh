#!/usr/bin/env bash

# === Configuration ===
LOGDIR="/var/log/clamav"
LOGFILE="${LOGDIR}/clamav-scan.log"
INFECTED_LOG="${LOGDIR}/infected.log"
NOTIFY_CMD="/usr/local/bin/notify-me"

# === Setup ===
mkdir -p "$LOGDIR"
TMP_INFECTED=$(mktemp)

echo "===== ClamAV Scan Started at $(date) =====" >> "$LOGFILE"

# Update virus database
echo "[*] Updating ClamAV database..." >> "$LOGFILE"
freshclam >> "$LOGFILE" 2>&1

# Run scan
echo "[*] Starting full system scan..." >> "$LOGFILE"
/usr/bin/clamscan -r --infected --bell --log="$INFECTED_LOG" / >> "$LOGFILE" 2>&1

echo "===== ClamAV Scan Finished at $(date) =====" >> "$LOGFILE"

# Extract found infections (lines ending with 'FOUND')
grep 'FOUND$' "$INFECTED_LOG" > "$TMP_INFECTED"

if [[ -s "$TMP_INFECTED" ]]; then
    echo "[!] Infected files found! Sending alert..." >> "$LOGFILE"
    ALERT_MSG="ClamAV Alert on $(hostname): $(tr '\n' ' ' < "$TMP_INFECTED" | cut -c1-1000)"
    $NOTIFY_CMD "$ALERT_MSG"
else
    echo "[✓] No infected files found." >> "$LOGFILE"
fi

rm -f "$TMP_INFECTED"
