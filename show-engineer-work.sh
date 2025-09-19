#!/bin/bash
# Show current work of each engineer with context
# Usage: ./show-engineer-work.sh [session-name]

SESSION=${1:-curation-dev}

# ANSI color codes
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   👷 Engineer Work Status - $(date '+%H:%M:%S')${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

for i in 1 2 3; do
    if tmux has-session -t $SESSION 2>/dev/null && tmux list-windows -t $SESSION | grep -q "^$i:"; then
        window_name=$(tmux list-windows -t $SESSION -F "#{window_index} #{window_name}" | grep "^$i " | cut -d' ' -f2-)
        
        echo -e "${YELLOW}════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Engineer $i: $window_name${NC}"
        echo -e "${YELLOW}════════════════════════════════════════${NC}"
        
        # Get the last 40 lines, filter out UI elements
        output=$(tmux capture-pane -t $SESSION:$i -p -S -40 2>/dev/null | \
            grep -v "^╭" | \
            grep -v "^│" | \
            grep -v "^╰" | \
            grep -v "shortcuts" | \
            grep -v "Bypassing")
        
        # Extract key information
        echo -e "\n${GREEN}📍 Current Activity:${NC}"
        echo "$output" | grep -E "^[●✶✻◉]" | tail -3 | sed 's/^/  /'
        
        echo -e "\n${GREEN}📂 Files Being Worked On:${NC}"
        echo "$output" | grep -E "(Read|Write|Edit|Create|Update).*\.(java|md|feature)" | tail -5 | sed 's/^/  /'
        
        echo -e "\n${GREEN}📋 Active Tasks:${NC}"
        echo "$output" | grep -E "☐|☑" | head -5 | sed 's/^/  /'
        
        # Check for any code being written
        code_snippet=$(echo "$output" | grep -A2 -E "^(public|private|protected|class|interface|@)" | head -10)
        if [ ! -z "$code_snippet" ]; then
            echo -e "\n${GREEN}💻 Code Snippet:${NC}"
            echo "$code_snippet" | sed 's/^/  /'
        fi
        
        # Check for any errors
        errors=$(echo "$output" | grep -iE "error|exception|failed" | tail -3)
        if [ ! -z "$errors" ]; then
            echo -e "\n${RED}⚠️  Issues:${NC}"
            echo "$errors" | sed 's/^/  /'
        fi
        
        echo ""
    fi
done

# Show recent git commits
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📦 Recent Git Activity:${NC}"
cd ${PROJECT_ROOT}
git log --oneline -5 2>/dev/null | sed 's/^/  /'

echo ""
echo -e "${GREEN}💡 To see full output: tmux attach -t $SESSION -r${NC}"