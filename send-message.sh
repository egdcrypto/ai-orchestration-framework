#!/bin/bash
# Send messages to engineers in tmux sessions
# Usage: ./send-message.sh <session:window> "message"

TARGET=$1
MESSAGE=$2

if [ -z "$TARGET" ] || [ -z "$MESSAGE" ]; then
    echo "Usage: $0 <session:window> \"message\""
    echo "Example: $0 myproject-dev:1 \"Continue with your task\""
    exit 1
fi

# Send message to tmux pane
tmux send-keys -t "$TARGET" "$MESSAGE" C-m

echo "✓ Message sent to $TARGET"