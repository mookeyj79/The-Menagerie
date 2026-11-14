#!/usr/bin/env bash

# === Configuration ===
LOGFILE="/var/log/aide/aide-review.log"
AIDE_DB="/var/lib/aide/aide.db"
AIDE_NEW_DB="/var/lib/aide/aide.db.new"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)

# === Run AIDE check and display results ===
echo "===== [$TIMESTAMP] AIDE Check Started =====" | tee -a "$LOGFILE"
sudo aide --check | tee /tmp/aide-check.out
echo "===== AIDE Check Finished =====" | tee -a "$LOGFILE"

# === Ask if user wants to rebaseline ===
if grep -qE "Changed files:|Added files:|Removed files:" /tmp/aide-check.out; then
    echo ""
    echo "[!] Changes detected. Review above carefully."
    read -p "Rebaseline AIDE database? (y/N): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "[$TIMESTAMP] User approved rebaseline on $HOSTNAME" | tee -a "$LOGFILE"
        sudo aideinit
        sudo mv "$AIDE_NEW_DB" "$AIDE_DB"
        echo "[$TIMESTAMP] AIDE database rebaselined successfully." | tee -a "$LOGFILE"
    else
        echo "[$TIMESTAMP] Rebaseline skipped by user." | tee -a "$LOGFILE"
    fi
else
    echo "[$TIMESTAMP] No changes detected — no rebaseline needed." | tee -a "$LOGFILE"
fi

# Cleanup
rm -f /tmp/aide-check.out
