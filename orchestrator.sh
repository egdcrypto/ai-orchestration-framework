#!/bin/bash
# Unified Orchestration System
# Reads engineer configuration from YAML and manages the entire orchestration lifecycle
# Usage: ./orchestrator.sh [config-file] [command]

set -e

# Default values
CONFIG_FILE="${1:-engineers.yaml}"
COMMAND="${2:-start}"

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    echo "Usage: $0 [config-file] [command]"
    echo "Commands: start, stop, status, monitor, broadcast"
    echo ""
    echo "Create a configuration file based on engineers.yaml.example"
    exit 1
fi

# Extract configuration values
PROJECT=$(grep "^project:" "$CONFIG_FILE" | cut -d'"' -f2)
SESSION_NAME=$(grep "^session_name:" "$CONFIG_FILE" | cut -d'"' -f2 || echo "project-dev")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Directories and files
BRIEFING_DIR="/tmp/${SESSION_NAME}_briefings"
ENGINEER_REGISTRY="/tmp/${SESSION_NAME}_engineers.txt"
LOG_FILE="/tmp/${SESSION_NAME}_orchestration.log"
NOTIFICATION_LOG="/tmp/${SESSION_NAME}_notifications.log"

# Notification settings from environment or config
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"
DISCORD_WEBHOOK="${DISCORD_WEBHOOK:-}"
TEAMS_WEBHOOK="${TEAMS_WEBHOOK:-}"

# Function to parse engineers from YAML
parse_engineers() {
    if command -v python3 &> /dev/null; then
        python3 << EOF
import yaml
import sys

try:
    with open("$CONFIG_FILE", 'r') as f:
        config = yaml.safe_load(f)

    engineers = config.get('engineers', [])
    for eng in engineers:
        print(f"{eng['id']}|{eng['name']}|{eng.get('role', 'unspecified')}")
except:
    sys.exit(1)
EOF
    else
        # Basic parsing fallback
        awk '/^  - id:/{id=$3} /^    name:/{gsub(/"/, "", $2); print id "|" $2 "|unknown"}' "$CONFIG_FILE"
    fi
}

# Function to extract briefing for an engineer
extract_briefing() {
    local eng_id=$1

    if command -v python3 &> /dev/null; then
        python3 << EOF
import yaml

with open("$CONFIG_FILE", 'r') as f:
    config = yaml.safe_load(f)

engineers = config.get('engineers', [])
for eng in engineers:
    if eng['id'] == $eng_id:
        briefing = eng.get('briefing', 'No briefing provided')
        print(briefing)
        break
EOF
    else
        echo "No briefing available (Python required for full briefing support)"
    fi
}

# Start orchestration
start_orchestration() {
    echo -e "${BLUE}🚀 Starting Orchestration Framework${NC}"
    echo "📋 Project: $PROJECT"
    echo "🔧 Session: $SESSION_NAME"
    echo "📖 Config: $CONFIG_FILE"

    # Check if session exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Session already exists${NC}"
        read -p "Kill existing session? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            tmux kill-session -t "$SESSION_NAME"
        else
            echo "Attaching to existing session..."
            tmux attach -t "$SESSION_NAME"
            exit 0
        fi
    fi

    # Create directories
    mkdir -p "$BRIEFING_DIR"

    # Create orchestrator session
    tmux new-session -d -s "$SESSION_NAME" -n "orchestrator"
    tmux send-keys -t "$SESSION_NAME:0" "# 🎯 Orchestrator for $PROJECT" C-m
    tmux send-keys -t "$SESSION_NAME:0" "# Configuration: $CONFIG_FILE" C-m
    tmux send-keys -t "$SESSION_NAME:0" "# Started: $(date)" C-m

    # Create registry
    echo "# Engineer Registry for $SESSION_NAME" > "$ENGINEER_REGISTRY"
    echo "# Generated: $(date)" >> "$ENGINEER_REGISTRY"
    echo "" >> "$ENGINEER_REGISTRY"

    # Create engineers
    ENGINEER_COUNT=0
    parse_engineers | while IFS='|' read -r ENG_ID ENG_NAME ENG_ROLE; do
        if [ -n "$ENG_ID" ]; then
            echo -e "${GREEN}✓${NC} Creating Engineer $ENG_ID: $ENG_NAME ($ENG_ROLE)"

            # Create tmux window
            tmux new-window -t "$SESSION_NAME:$ENG_ID" -n "eng$ENG_ID-$ENG_ROLE"

            # Extract and save briefing
            BRIEFING_FILE="$BRIEFING_DIR/engineer${ENG_ID}_briefing.txt"
            extract_briefing "$ENG_ID" > "$BRIEFING_FILE"

            # Send initial setup to engineer window
            tmux send-keys -t "$SESSION_NAME:$ENG_ID" "# Engineer $ENG_ID: $ENG_NAME" C-m
            tmux send-keys -t "$SESSION_NAME:$ENG_ID" "# Role: $ENG_ROLE" C-m
            tmux send-keys -t "$SESSION_NAME:$ENG_ID" "# Session: $SESSION_NAME" C-m
            tmux send-keys -t "$SESSION_NAME:$ENG_ID" "#" C-m
            tmux send-keys -t "$SESSION_NAME:$ENG_ID" "# === BRIEFING ===" C-m

            # Send briefing content
            while IFS= read -r line; do
                tmux send-keys -t "$SESSION_NAME:$ENG_ID" "# $line" C-m
            done < "$BRIEFING_FILE"

            tmux send-keys -t "$SESSION_NAME:$ENG_ID" "# === END BRIEFING ===" C-m
            tmux send-keys -t "$SESSION_NAME:$ENG_ID" "#" C-m
            tmux send-keys -t "$SESSION_NAME:$ENG_ID" "# Ready for instructions..." C-m

            # Record in registry
            echo "Engineer $ENG_ID: $ENG_NAME ($ENG_ROLE) - Window $ENG_ID" >> "$ENGINEER_REGISTRY"
            ENGINEER_COUNT=$((ENGINEER_COUNT + 1))
        fi
    done

    echo ""
    echo -e "${GREEN}✅ Orchestration setup complete!${NC}"
    echo "📊 Created $ENGINEER_COUNT engineers"
    echo "📝 Registry: $ENGINEER_REGISTRY"

    # Send notification
    send_notification "INFO" "Orchestration started with $ENGINEER_COUNT engineers for project $PROJECT"
    echo ""
    echo "Attaching to session..."
    sleep 2

    tmux select-window -t "$SESSION_NAME:0"
    tmux attach -t "$SESSION_NAME"
}

# Stop orchestration
stop_orchestration() {
    echo -e "${YELLOW}Stopping orchestration session: $SESSION_NAME${NC}"

    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux kill-session -t "$SESSION_NAME"
        echo -e "${GREEN}✓ Session stopped${NC}"
        send_notification "INFO" "Orchestration stopped for project $PROJECT"
    else
        echo -e "${RED}Session not found${NC}"
    fi
}

# Send notification to configured platforms
send_notification() {
    local level="$1"  # INFO, WARNING, ERROR
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Log notification
    echo "[$timestamp] [$level] $message" >> "$NOTIFICATION_LOG"

    # Console output with colors
    case $level in
        ERROR)
            echo -e "${RED}❌ $message${NC}"
            ;;
        WARNING)
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        INFO)
            echo -e "${GREEN}ℹ️  $message${NC}"
            ;;
    esac

    # Slack notification
    if [ -n "$SLACK_WEBHOOK" ]; then
        local emoji=":information_source:"
        [ "$level" = "ERROR" ] && emoji=":x:"
        [ "$level" = "WARNING" ] && emoji=":warning:"

        curl -X POST "$SLACK_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{\"text\": \"$emoji *[$PROJECT]* $level: $message\"}" \
            2>/dev/null
    fi

    # Discord notification
    if [ -n "$DISCORD_WEBHOOK" ]; then
        local color="3066993"  # Blue for INFO
        [ "$level" = "ERROR" ] && color="15158332"  # Red
        [ "$level" = "WARNING" ] && color="16776960"  # Yellow

        curl -X POST "$DISCORD_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{
                \"embeds\": [{
                    \"title\": \"$PROJECT Orchestration\",
                    \"description\": \"$message\",
                    \"color\": $color,
                    \"fields\": [
                        {\"name\": \"Level\", \"value\": \"$level\", \"inline\": true},
                        {\"name\": \"Session\", \"value\": \"$SESSION_NAME\", \"inline\": true}
                    ],
                    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\"
                }]
            }" \
            2>/dev/null
    fi

    # Microsoft Teams notification
    if [ -n "$TEAMS_WEBHOOK" ]; then
        local theme_color="0076D7"  # Blue for INFO
        [ "$level" = "ERROR" ] && theme_color="CC0000"  # Red
        [ "$level" = "WARNING" ] && theme_color="FF9900"  # Orange

        curl -X POST "$TEAMS_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{
                \"@type\": \"MessageCard\",
                \"@context\": \"http://schema.org/extensions\",
                \"themeColor\": \"$theme_color\",
                \"summary\": \"$PROJECT Orchestration $level\",
                \"sections\": [{
                    \"activityTitle\": \"$PROJECT Orchestration\",
                    \"facts\": [
                        {\"name\": \"Level:\", \"value\": \"$level\"},
                        {\"name\": \"Session:\", \"value\": \"$SESSION_NAME\"},
                        {\"name\": \"Message:\", \"value\": \"$message\"}
                    ]
                }]
            }" \
            2>/dev/null
    fi
}

# Show status
show_status() {
    echo -e "${BLUE}📊 Orchestration Status${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo -e "${GREEN}✓ Session active: $SESSION_NAME${NC}"
        echo ""
        echo "Engineers:"

        if [ -f "$ENGINEER_REGISTRY" ]; then
            grep "^Engineer" "$ENGINEER_REGISTRY" | while read line; do
                echo "  $line"
            done
        fi

        echo ""
        echo "Windows:"
        tmux list-windows -t "$SESSION_NAME" -F "  Window #{window_index}: #{window_name}"
    else
        echo -e "${RED}✗ Session not active: $SESSION_NAME${NC}"
    fi
}

# Monitor engineers
monitor_engineers() {
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo -e "${RED}Session not found: $SESSION_NAME${NC}"
        exit 1
    fi

    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   📊 Engineer Monitor - $PROJECT${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Monitor each engineer window
    parse_engineers | while IFS='|' read -r ENG_ID ENG_NAME ENG_ROLE; do
        if [ -n "$ENG_ID" ]; then
            echo ""
            echo -e "${YELLOW}Engineer $ENG_ID: $ENG_NAME${NC}"

            # Get last activity
            output=$(tmux capture-pane -t "$SESSION_NAME:$ENG_ID" -p 2>/dev/null | tail -5 | grep -v "^$")
            if [ -n "$output" ]; then
                echo "$output" | while read line; do
                    echo "  ${line:0:70}..."
                done
            else
                echo -e "  ${RED}No activity${NC}"
            fi
        fi
    done

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Broadcast message to all engineers
broadcast_message() {
    local message="${3:-$2}"

    if [ -z "$message" ]; then
        echo "Usage: $0 $CONFIG_FILE broadcast \"message\""
        exit 1
    fi

    echo -e "${BLUE}📢 Broadcasting: $message${NC}"

    parse_engineers | while IFS='|' read -r ENG_ID ENG_NAME ENG_ROLE; do
        if [ -n "$ENG_ID" ]; then
            if tmux send-keys -t "$SESSION_NAME:$ENG_ID" "$message" C-m 2>/dev/null; then
                echo -e "  ${GREEN}✓${NC} Sent to Engineer $ENG_ID ($ENG_NAME)"
            else
                echo -e "  ${RED}✗${NC} Failed to send to Engineer $ENG_ID"
                send_notification "WARNING" "Failed to send message to Engineer $ENG_ID ($ENG_NAME)"
            fi
        fi
    done
}

# Main command dispatcher
case "$COMMAND" in
    start)
        start_orchestration
        ;;
    stop)
        stop_orchestration
        ;;
    status)
        show_status
        ;;
    monitor)
        monitor_engineers
        ;;
    broadcast)
        broadcast_message "$@"
        ;;
    *)
        echo "Usage: $0 [config-file] [command]"
        echo ""
        echo "Commands:"
        echo "  start     - Start orchestration session"
        echo "  stop      - Stop orchestration session"
        echo "  status    - Show session status"
        echo "  monitor   - Monitor all engineers"
        echo "  broadcast - Send message to all engineers"
        echo ""
        echo "Examples:"
        echo "  $0 engineers.yaml start"
        echo "  $0 engineers.yaml monitor"
        echo "  $0 engineers.yaml broadcast \"Status update please\""
        exit 1
        ;;
esac