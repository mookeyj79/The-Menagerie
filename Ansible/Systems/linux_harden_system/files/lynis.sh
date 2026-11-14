#!/usr/bin/env bash

# === Configuration ===
LOGDIR="/var/log/lynis"
LOGFILE="${LOGDIR}/lynis-scan.log"
NOTIFY_CMD="/usr/local/bin/notify-me"  # Replace this with your actual script or command
AUDITOR="$(hostname)"  # Use system name as auditor tag

# === Setup ===
mkdir -p "$LOGDIR"
TMP_WARNINGS=$(mktemp)

echo "===== Lynis Scan Started at $(date) =====" >> "$LOGFILE"

# Run Lynis system audit in quiet mode
lynis audit system --auditor "$AUDITOR" --quiet >> "$LOGFILE" 2>&1

echo "===== Lynis Scan Finished at $(date) =====" >> "$LOGFILE"

# Extract only warnings and suggestions
grep -E "^\s*(Warning|Suggestion):" "$LOGFILE" > "$TMP_WARNINGS"

# Check for and notify on findings
if [[ -s "$TMP_WARNINGS" ]]; then
    echo "[!] Warnings or suggestions found. Sending alert..." >> "$LOGFILE"
    
    # Convert to a single line and trim message
    ALERT_MSG="Lynis findings on $AUDITOR: $(tr '\n' ' ' < "$TMP_WARNINGS" | cut -c1-1000)"
    $NOTIFY_CMD "$ALERT_MSG"
else
    echo "[✓] No significant issues found." >> "$LOGFILE"
fi

# Cleanup
rm -f "$TMP_WARNINGS"
