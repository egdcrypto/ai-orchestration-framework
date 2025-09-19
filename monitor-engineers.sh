#!/bin/bash
# Monitor all engineers in a session
# Usage: ./monitor-engineers.sh [session-name]

SESSION_NAME="${1:-orchestration-dev}"
REGISTRY="/tmp/${SESSION_NAME}_engineers.txt"

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   📊 Engineer Monitor - Session: $SESSION_NAME${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${RED}❌ Session not found: $SESSION_NAME${NC}"
    exit 1
fi

# Function to get last activity from a window
check_engineer_status() {
    local window_id=$1
    local window_name=$2

    echo -e "${YELLOW}━━━ Window $window_id: $window_name ━━━${NC}"

    # Get last 10 lines from the pane
    local output=$(tmux capture-pane -t "$SESSION_NAME:$window_id" -p 2>/dev/null | tail -10)

    if [ -z "$output" ]; then
        echo -e "${RED}  No activity detected${NC}"
    else
        # Show last meaningful lines
        echo "$output" | grep -v "^$" | tail -5 | while IFS= read -r line; do
            # Truncate long lines
            echo "  ${line:0:70}"
        done
    fi
    echo ""
}

# Monitor each window except orchestrator
tmux list-windows -t "$SESSION_NAME" -F "#{window_index} #{window_name}" | while read window_id window_name; do
    if [ "$window_id" != "0" ]; then
        check_engineer_status "$window_id" "$window_name"
    fi
done

# Show orchestrator status
echo -e "${GREEN}━━━ Orchestrator Status ━━━${NC}"
orchestrator_status=$(tmux capture-pane -t "$SESSION_NAME:0" -p 2>/dev/null | grep -v "^$" | tail -3)
if [ -n "$orchestrator_status" ]; then
    echo "$orchestrator_status" | while IFS= read -r line; do
        echo "  ${line:0:70}"
    done
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}💡 Quick Actions:${NC}"
echo "  Broadcast: for i in \$(seq 1 3); do ./send-message.sh $SESSION_NAME:\$i \"Status update\"; done"
echo "  Attach: tmux attach -t $SESSION_NAME"
echo "  List: ./list-engineers.sh $SESSION_NAME"