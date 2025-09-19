#!/bin/bash
# Quick progress check for all engineers in a session
# Usage: ./check-progress.sh [session-name]

SESSION=${1:-project-dev}

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🔍 Quick Progress Check - Session: $SESSION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if session exists
if ! tmux has-session -t $SESSION 2>/dev/null; then
    echo -e "${RED}❌ Session $SESSION not found${NC}"
    exit 1
fi

# Function to extract engineer progress
check_engineer() {
    local window=$1
    local name=$2
    
    echo -e "${YELLOW}═══ Engineer $window: $name ═══${NC}"
    
    # Get current activity
    current=$(tmux capture-pane -t $SESSION:$window -p 2>/dev/null | grep -E "^[●✶✻◉]" | tail -1 | sed 's/^[●✶✻◉] *//' | cut -c1-80)
    if [ ! -z "$current" ]; then
        echo -e "${GREEN}Current:${NC} $current..."
    fi
    
    # Get recent file operations
    files=$(tmux capture-pane -t $SESSION:$window -p 2>/dev/null | grep -E "^[●✶✻◉] (Read|Write|Edit|Search|Create)" | tail -5)
    if [ ! -z "$files" ]; then
        echo -e "${PURPLE}Recent Files:${NC}"
        echo "$files" | while IFS= read -r line; do
            echo "  $line" | cut -c1-80
        done
    fi
    
    # Get TODO status
    todos=$(tmux capture-pane -t $SESSION:$window -p 2>/dev/null | grep -E "☐|☑" | tail -5)
    if [ ! -z "$todos" ]; then
        echo -e "${BLUE}Tasks:${NC}"
        echo "$todos" | while IFS= read -r line; do
            echo "  $line" | cut -c1-80
        done
    fi
    
    # Check for errors or blockers
    errors=$(tmux capture-pane -t $SESSION:$window -p 2>/dev/null | grep -iE "error|failed|exception" | tail -3)
    if [ ! -z "$errors" ]; then
        echo -e "${RED}⚠️  Potential Issues:${NC}"
        echo "$errors" | while IFS= read -r line; do
            echo "  $line" | cut -c1-80
        done
    fi
    
    echo ""
}

# Check each engineer
for i in 1 2 3; do
    if tmux list-windows -t $SESSION -F "#{window_index} #{window_name}" | grep -q "^$i "; then
        window_name=$(tmux list-windows -t $SESSION -F "#{window_index} #{window_name}" | grep "^$i " | cut -d' ' -f2-)
        check_engineer $i "$window_name"
    fi
done

# Quick summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}💡 Quick Actions:${NC}"
echo "1. Send message to engineer: ./send-message.sh $SESSION:1 \"Status update please\""
echo "2. Attach to session: tmux attach -t $SESSION"
echo "3. Full monitor: ./monitor-implementation.sh ${SESSION%-dev}"
echo ""

# Show LOG file updates
DOMAIN=${SESSION%-dev}
FEATURE_DIR="${PROJECT_ROOT}/src/test/resources/features/$DOMAIN"
if [ -d "$FEATURE_DIR" ]; then
    echo -e "${BLUE}📝 Recent LOG Updates:${NC}"
    recent_logs=$(find "$FEATURE_DIR" -name "*_LOG.md" -mmin -60 2>/dev/null | head -5)
    if [ ! -z "$recent_logs" ]; then
        echo "$recent_logs" | while read log; do
            echo -e "  ${GREEN}✓${NC} $(basename $log) - Updated $(date -r "$log" '+%H:%M')"
        done
    else
        echo "  No LOG files updated in last hour"
    fi
fi