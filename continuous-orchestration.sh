#!/bin/bash
# Continuous Orchestration Loop for Engineer Management

SESSION_NAME="${1:-project-dev}"
DOMAIN="${2:-project}"
ITERATION=1
LOG_FILE="/tmp/orchestration-loop.log"

echo "🔄 Starting Continuous Orchestration Loop for $DOMAIN" | tee -a $LOG_FILE
echo "Session: $SESSION_NAME" | tee -a $LOG_FILE
echo "Started: $(date)" | tee -a $LOG_FILE

while true; do
    echo "" | tee -a $LOG_FILE
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a $LOG_FILE
    echo "🔄 Orchestration Loop Iteration $ITERATION - $(date)" | tee -a $LOG_FILE
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a $LOG_FILE
    
    # Check if session is still running
    if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
        echo "❌ Session $SESSION_NAME not found. Exiting loop." | tee -a $LOG_FILE
        break
    fi
    
    # Monitor implementation status
    echo "📊 Checking implementation status..." | tee -a $LOG_FILE
    ./orchestration-framework/monitor-implementation.sh $DOMAIN 2>/dev/null | head -20 | tee -a $LOG_FILE
    
    # Check git status for recent activity
    RECENT_COMMITS=$(git log --oneline --since="30 minutes ago" | wc -l)
    echo "📝 Recent commits (30 min): $RECENT_COMMITS" | tee -a $LOG_FILE
    
    # Send progress checks to engineers
    echo "📤 Sending progress checks to engineers..." | tee -a $LOG_FILE
    
    ./send-message.sh $SESSION_NAME:1 "Progress check! Current status? Update your LOG file." 2>/dev/null
    ./send-message.sh $SESSION_NAME:2 "Status update! What are you working on? Update LOG file." 2>/dev/null
    ./send-message.sh $SESSION_NAME:3 "Progress report! Update your LOG file." 2>/dev/null
    
    # Check for build status
    BUILD_STATUS=$(./gradlew build --quiet 2>&1 && echo "SUCCESS" || echo "FAILED")
    echo "🔨 Build Status: $BUILD_STATUS" | tee -a $LOG_FILE
    
    # Wait for next iteration
    echo "⏰ Waiting 30 minutes for next check..." | tee -a $LOG_FILE
    
    # Increment iteration counter
    ITERATION=$((ITERATION + 1))
    
    # Sleep for 30 minutes (1800 seconds)
    sleep 1800
done

echo "🏁 Continuous orchestration loop ended at $(date)" | tee -a $LOG_FILE