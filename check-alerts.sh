#!/bin/bash
# Check for orchestration alerts and send email if found

ALERT_FILE="/tmp/orchestration-alerts.log"
EMAIL="${ORCHESTRATOR_EMAIL:-admin@example.com}"
LAST_CHECK_FILE="/tmp/last-alert-check"

# Get current timestamp
CURRENT_TIME=$(date +%s)

# Get last check time (default to 15 minutes ago if first run)
if [ -f "$LAST_CHECK_FILE" ]; then
    LAST_CHECK=$(cat "$LAST_CHECK_FILE")
else
    LAST_CHECK=$((CURRENT_TIME - 900))
fi

# Check for new alerts
if [ -f "$ALERT_FILE" ]; then
    # Find alerts newer than last check
    NEW_ALERTS=$(awk -v last="$LAST_CHECK" -v curr="$CURRENT_TIME" '
        BEGIN { count = 0 }
        {
            # Extract timestamp from log line
            if (match($0, /\[([0-9-]+ [0-9:]+)\]/, arr)) {
                cmd = "date -d \"" arr[1] "\" +%s"
                cmd | getline timestamp
                close(cmd)
                
                if (timestamp > last && timestamp <= curr) {
                    print $0
                    count++
                }
            }
        }
        END { exit (count > 0 ? 0 : 1) }
    ' "$ALERT_FILE")
    
    if [ $? -eq 0 ]; then
        # Send email with new alerts
        echo "Subject: Orchestration Alerts - $(date)" > /tmp/alert-email.txt
        echo "" >> /tmp/alert-email.txt
        echo "New orchestration alerts detected:" >> /tmp/alert-email.txt
        echo "" >> /tmp/alert-email.txt
        echo "$NEW_ALERTS" >> /tmp/alert-email.txt
        
        # Send email (requires mail/sendmail configured)
        cat /tmp/alert-email.txt | mail -s "Orchestration Alerts" "$EMAIL" 2>/dev/null || \
            echo "Email sending failed. Alerts saved to $ALERT_FILE"
    fi
fi

# Update last check time
echo "$CURRENT_TIME" > "$LAST_CHECK_FILE"