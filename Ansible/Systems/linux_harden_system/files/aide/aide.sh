#!/usr/bin/env bash

LOGFILE="/var/log/aide/aide-scan.log"
NOTIFY_CMD="/usr/local/bin/notify-me"
HOST="$(hostname)"
TMP_OUTPUT=$(mktemp)

mkdir -p /var/log/aide

echo "===== AIDE Check Started at $(date) =====" >> "$LOGFILE"
aide --check >> "$LOGFILE" 2>&1
echo "===== AIDE Check Finished at $(date) =====" >> "$LOGFILE"

# Extract lines indicating actual changes
grep -E "^(Changed|Added|Removed) files:" "$LOGFILE" > "$TMP_OUTPUT"

if [[ -s "$TMP_OUTPUT" ]]; then
    MSG="AIDE Alert on $HOST: $(tr '\n' ' ' < "$TMP_OUTPUT" | cut -c1-1000)"
    $NOTIFY_CMD "$MSG"
else
    echo "[✓] No integrity violations found." >> "$LOGFILE"
fi

rm -f "$TMP_OUTPUT"
