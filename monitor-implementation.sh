#!/bin/bash
# Universal implementation monitoring script
# Usage: ./monitor-implementation.sh <domain> [session-name]

DOMAIN=${1:-project}
SESSION_NAME=${2:-${DOMAIN}-dev}
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
FEATURE_DIR="src/test/resources/features/${DOMAIN}"
IMPL_DIR="${FEATURE_DIR}/implementation"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   📊 Implementation Monitor - ${DOMAIN^^} Domain${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if session exists
if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo -e "${RED}❌ Session $SESSION_NAME not found${NC}"
    echo "   Run: ./orchestrate-${DOMAIN}.sh to start"
    exit 1
fi

# Session info
echo -e "${YELLOW}📋 Session:${NC} $SESSION_NAME"
echo -e "${YELLOW}📁 Domain:${NC} $DOMAIN"
echo -e "${YELLOW}🕐 Time:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Feature statistics
if [ -d "$PROJECT_ROOT/$FEATURE_DIR" ]; then
    echo -e "${BLUE}📈 Feature Statistics:${NC}"
    total_features=$(ls $PROJECT_ROOT/$FEATURE_DIR/*.feature 2>/dev/null | wc -l)
    echo "   Total features: $total_features"
    
    if [ -d "$PROJECT_ROOT/$IMPL_DIR" ]; then
        total_todos=$(find $PROJECT_ROOT/$IMPL_DIR -name "*_TODO.md" | wc -l)
        echo "   TODO files: $total_todos"
    fi
    echo ""
fi

# Engineer status
echo -e "${BLUE}👥 Engineer Status:${NC}"
for i in 1 2 3; do
    if tmux list-windows -t $SESSION_NAME -F "#{window_index} #{window_name}" | grep -q "^$i "; then
        window_name=$(tmux list-windows -t $SESSION_NAME -F "#{window_index} #{window_name}" | grep "^$i " | cut -d' ' -f2-)
        
        # Get current activity from Claude
        current_activity=$(tmux capture-pane -t $SESSION_NAME:$i -p 2>/dev/null | grep -E "^[●✶✻◉]" | tail -1 | sed 's/^[●✶✻◉] *//')
        
        # Get TODO items if visible
        todo_count=$(tmux capture-pane -t $SESSION_NAME:$i -p 2>/dev/null | grep -c "☐" | head -1)
        done_count=$(tmux capture-pane -t $SESSION_NAME:$i -p 2>/dev/null | grep -c "☑" | head -1)
        
        echo -e "   ${YELLOW}$window_name:${NC}"
        if [ ! -z "$current_activity" ]; then
            echo -e "     📍 ${current_activity:0:70}..."
        fi
        if [ $todo_count -gt 0 ] || [ $done_count -gt 0 ]; then
            echo -e "     📋 Tasks: $done_count done, $todo_count pending"
        fi
    fi
done
echo ""

# Detailed Engineer Progress (new section)
echo -e "${BLUE}🔍 Detailed Engineer Progress:${NC}"
for i in 1 2 3; do
    if tmux list-windows -t $SESSION_NAME -F "#{window_index} #{window_name}" | grep -q "^$i "; then
        window_name=$(tmux list-windows -t $SESSION_NAME -F "#{window_index} #{window_name}" | grep "^$i " | cut -d' ' -f2-)
        echo -e "\n   ${YELLOW}=== $window_name ===${NC}"
        
        # Get last 15 lines of meaningful output (excluding empty lines and UI elements)
        tmux capture-pane -t $SESSION_NAME:$i -p 2>/dev/null | \
            grep -v "^$" | \
            grep -v "^╭" | \
            grep -v "^│" | \
            grep -v "^╰" | \
            grep -v "for shortcuts" | \
            tail -15 | \
            sed 's/^/     /'
    fi
done
echo ""

# TODO Progress
if [ -d "$PROJECT_ROOT/$IMPL_DIR" ]; then
    echo -e "${BLUE}📋 TODO Progress:${NC}"
    for todo in $PROJECT_ROOT/$IMPL_DIR/*_TODO.md; do
        if [ -f "$todo" ]; then
            feature=$(basename "$todo" _TODO.md)
            total=$(grep -c "^- \[ \]" "$todo" 2>/dev/null || echo 0)
            done=$(grep -c "^- \[x\]" "$todo" 2>/dev/null || echo 0)
            
            if [ $total -gt 0 ]; then
                percent=$((done * 100 / total))
                
                # Progress bar
                bar_length=20
                filled=$((percent * bar_length / 100))
                empty=$((bar_length - filled))
                
                printf "   %-25s [" "$feature:"
                printf "%${filled}s" | tr ' ' '█'
                printf "%${empty}s" | tr ' ' '░'
                printf "] %3d%% (%d/%d)\n" $percent $done $total
            else
                echo "   $feature: No tasks found"
            fi
        fi
    done
    echo ""
fi

# Recent LOG entries
if [ -d "$PROJECT_ROOT/$IMPL_DIR" ]; then
    echo -e "${BLUE}📝 Recent Progress (last 2 hours):${NC}"
    found_recent=false
    for log in $PROJECT_ROOT/$IMPL_DIR/*_LOG.md; do
        if [ -f "$log" ]; then
            # Find entries from last 2 hours
            recent=$(grep -E "^## \[.*\]" "$log" 2>/dev/null | tail -5)
            if [ ! -z "$recent" ]; then
                found_recent=true
                echo -e "   ${YELLOW}$(basename $log):${NC}"
                echo "$recent" | while read line; do
                    echo "     $line"
                done
                echo ""
            fi
        fi
    done
    
    if [ "$found_recent" = false ]; then
        echo "   No recent updates in LOG files"
        echo ""
    fi
fi

# Build status
echo -e "${BLUE}🔨 Build Status:${NC}"
cd $PROJECT_ROOT/backend 2>/dev/null
if timeout 10 ./gradlew build --quiet 2>/dev/null; then
    echo -e "   ${GREEN}✅ BUILD PASSING${NC}"
else
    echo -e "   ${RED}❌ BUILD FAILING${NC}"
    echo "   Check window 4 for details"
fi
echo ""

# Git status
echo -e "${BLUE}📦 Git Status:${NC}"
cd $PROJECT_ROOT
changes=$(git status --porcelain | wc -l)
if [ $changes -eq 0 ]; then
    echo -e "   ${GREEN}✓ No uncommitted changes${NC}"
else
    echo -e "   ${YELLOW}⚠ $changes files with changes${NC}"
    git status --short | head -5 | sed 's/^/   /'
    if [ $changes -gt 5 ]; then
        echo "   ... and $((changes - 5)) more"
    fi
fi
echo ""

# Quick actions
echo -e "${BLUE}🎯 Quick Actions:${NC}"
echo "   1. Send progress check to all engineers:"
echo -e "      ${YELLOW}$ORCHESTRATOR_DIR/send-claude-message.sh $SESSION_NAME:0 \"Progress check time!\"${NC}"
echo ""
echo "   2. Attach to session:"
echo -e "      ${YELLOW}tmux attach -t $SESSION_NAME${NC}"
echo ""
echo "   3. View specific engineer:"
echo -e "      ${YELLOW}tmux attach -t $SESSION_NAME -c 1${NC}"
echo ""

# Footer
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Press Ctrl+C to exit | Auto-refresh: watch -n 30 ./monitor-implementation.sh $DOMAIN"