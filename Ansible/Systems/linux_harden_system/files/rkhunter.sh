#!/usr/bin/env bash

# === Configuration ===
LOGDIR="/var/log/rkhunter"
LOGFILE="${LOGDIR}/rkhunter-scan.log"
NOTIFY_CMD="/usr/local/bin/notify-me"

# === Setup ===
mkdir -p "$LOGDIR"
TMP_WARNINGS=$(mktemp)

echo "===== RKhunter Scan Started at $(date) =====" >> "$LOGFILE"

# Update database
echo "[*] Updating RKhunter database..." >> "$LOGFILE"
rkhunter --update >> "$LOGFILE" 2>&1
rkhunter --propupd -q >> "$LOGFILE" 2>&1  # Update baseline (silently)

# Run scan
echo "[*] Running scan..." >> "$LOGFILE"
rkhunter --check --sk --rwo >> "$LOGFILE" 2>&1

echo "===== RKhunter Scan Finished at $(date) =====" >> "$LOGFILE"

# Extract relevant warnings
grep -E "Warning:|Possible Rootkit" "$LOGFILE" > "$TMP_WARNINGS"

if [[ -s "$TMP_WARNINGS" ]]; then
    echo "[!] Warnings detected! Sending alert..." >> "$LOGFILE"
    ALERT_MSG="RKhunter Alert on $(hostname): $(tr '\n' ' ' < "$TMP_WARNINGS" | cut -c1-1000)"
    $NOTIFY_CMD "$ALERT_MSG"
else
    echo "[✓] No issues found." >> "$LOGFILE"
fi

rm -f "$TMP_WARNINGS"
