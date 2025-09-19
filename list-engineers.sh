#!/bin/bash
# List all engineers in a session
# Usage: ./list-engineers.sh [session-name]

SESSION_NAME="${1:-orchestration-dev}"
REGISTRY="/tmp/${SESSION_NAME}_engineers.txt"

echo "🔍 Engineers in session: $SESSION_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "❌ Session not found: $SESSION_NAME"
    exit 1
fi

# List windows in session
echo "📊 Active Windows:"
tmux list-windows -t "$SESSION_NAME" -F "  Window #{window_index}: #{window_name} (#{pane_current_command})"

# Show engineer registry if it exists
if [ -f "$REGISTRY" ]; then
    echo ""
    echo "📝 Engineer Registry:"
    grep "^Engineer" "$REGISTRY" | while IFS= read -r line; do
        echo "  $line"
    done
else
    echo ""
    echo "⚠️  No engineer registry found at $REGISTRY"
fi

echo ""
echo "💡 Commands:"
echo "  Send message: ./send-message.sh $SESSION_NAME:<window_id> \"message\""
echo "  Monitor: ./monitor-engineers.sh $SESSION_NAME"
echo "  Attach: tmux attach -t $SESSION_NAME"