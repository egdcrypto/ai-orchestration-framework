#!/bin/bash
# Broadcast a message to all engineers in a session
# Usage: ./broadcast-message.sh [session-name] "message"

SESSION_NAME="${1}"
MESSAGE="${2}"

if [ -z "$SESSION_NAME" ] || [ -z "$MESSAGE" ]; then
    echo "Usage: $0 <session-name> \"message\""
    echo "Example: $0 myproject-dev \"Please provide status update\""
    exit 1
fi

echo "📢 Broadcasting to all engineers in $SESSION_NAME..."

# Get all windows except orchestrator (window 0)
tmux list-windows -t "$SESSION_NAME" -F "#{window_index}" 2>/dev/null | while read window_id; do
    if [ "$window_id" != "0" ]; then
        tmux send-keys -t "$SESSION_NAME:$window_id" "$MESSAGE" C-m
        echo "  ✓ Sent to Engineer $window_id"
    fi
done

echo "✅ Broadcast complete"