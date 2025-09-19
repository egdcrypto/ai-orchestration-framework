# Orchestration Guide

## Quick Start Instructions for Claude

When you start a new Claude session and want to continue with orchestration, provide this guide to Claude with instructions on what to do next.

## Overview

This project uses an AI orchestration framework to coordinate multiple Claude instances (engineers) working on different aspects of feature implementation. The framework uses tmux sessions to manage parallel development efforts.

## Key Directories

- **Orchestration Framework**: `/orchestration-framework/` - Contains scripts and templates
- **Feature Definitions**: `/src/test/resources/features/` - Gherkin feature files by domain
- **Engineer Briefings**: `/engineer[1-3]-briefing.md` - Role-specific instructions

## Current Status

### Active Domains
Check your project's `/src/test/resources/features/` directory for available domains.
Each domain can have its own orchestration session following the pattern: `<domain>-dev`

### Available Orchestration Scripts
- `orchestration-framework/generate-orchestrator.sh` - Generate new domain orchestrators
- Generated scripts will be named: `orchestrate-<domain>.sh`

### To Generate Orchestrator for New Domain
```bash
# List available domains
find src/test/resources/features -type d -mindepth 1 -maxdepth 1 | xargs -n1 basename

# Generate orchestrator for any domain
./orchestration-framework/generate-orchestrator.sh <domain-name>
```

## Common Commands

### Check Orchestration Status
```bash
# List active tmux sessions
tmux list-sessions

# Check specific session status (replace DOMAIN with actual domain name)
./orchestration-framework/check-progress.sh <DOMAIN>-dev

# Monitor implementation progress
./orchestration-framework/monitor-implementation.sh <DOMAIN>

# Show engineer work
./orchestration-framework/show-engineer-work.sh <DOMAIN>-dev
```

### Start New Orchestration
```bash
# For any existing orchestrator script
./orchestration-framework/orchestrate-<DOMAIN>.sh

# Generate and run orchestrator for new domain
./orchestration-framework/generate-orchestrator.sh <DOMAIN>
./orchestrate-<DOMAIN>.sh
```

### Interact with Engineers
```bash
# Send message to specific engineer (replace DOMAIN with actual domain)
./orchestration-framework/send-message.sh <DOMAIN>-dev:1 "Your message here"

# Send status check to all engineers
./orchestration-framework/send-message.sh <DOMAIN>-dev:0 "Status update please"

# Attach to session to see all engineers
tmux attach -t <DOMAIN>-dev
```

## How to Continue Orchestration

### Option 1: Resume Existing Session
If a session is already running:
```bash
# Check if session exists (replace DOMAIN with your domain)
tmux has-session -t <DOMAIN>-dev 2>/dev/null && echo "Session exists" || echo "No session"

# Attach to existing session
tmux attach -t <DOMAIN>-dev

# Send continuation message to engineers
./orchestration-framework/send-message.sh <DOMAIN>-dev:1 "Continue with your previous task. Check your last progress and resume."
```

### Option 2: Start Fresh Session
If starting new or session was terminated:
```bash
# Run the orchestration script for your domain
./orchestration-framework/orchestrate-<DOMAIN>.sh

# Or generate new orchestrator if needed
./orchestration-framework/generate-orchestrator.sh <DOMAIN>
./orchestrate-<DOMAIN>.sh
```

### Option 3: Check Progress and Direct Next Steps
```bash
# Check what's been completed (replace DOMAIN)
cd src/test/resources/features/<DOMAIN>/implementation
cat IMPLEMENTATION_PROGRESS.md

# Check individual feature progress
tail *_LOG.md

# Direct engineers to specific tasks
./orchestration-framework/send-message.sh <DOMAIN>-dev:1 "Focus on [specific feature] next"
```

## Architecture Reminders

### Hexagonal Architecture
- **Domain Layer**: Pure business logic, no framework dependencies
- **Application Layer**: Use cases, orchestration, transforms DTOs
- **Infrastructure Layer**: Controllers, REST endpoints, framework code

### Key Patterns
- Controllers only call application services
- Domain entities never import DTOs
- Use `ApiResponse` wrapper for all REST responses
- Follow clean architecture principles

## Troubleshooting

### Build Failures
```bash
# Check build status (adjust for your build tool)
# For Gradle:
./gradlew build

# For Maven:
mvn clean install

# For Node.js:
npm run build
```

### Engineer Stuck
```bash
# Check engineer's current state
tmux capture-pane -t <DOMAIN>-dev:1 -p | tail -50

# Send clarification
./orchestration-framework/send-message.sh <DOMAIN>-dev:1 "Here's clarification on your blocker..."
```

### Session Management
```bash
# Kill stuck session
tmux kill-session -t <DOMAIN>-dev

# List all windows in session
tmux list-windows -t <DOMAIN>-dev

# Switch to specific window
tmux select-window -t <DOMAIN>-dev:2
```

## Domain-Specific Next Steps

### For New Domains
1. **Generate Orchestrator**: Use `generate-orchestrator.sh` to create orchestration script
2. **Review Feature Files**: Check `/src/test/resources/features/<DOMAIN>/`
3. **Plan Implementation**: Create TODO files for each feature
4. **Start Orchestration**: Run the generated orchestrator script

### General Implementation Steps
1. **Domain Layer**: Create models, aggregates, and domain events
2. **Application Layer**: Implement services following hexagonal architecture
3. **Infrastructure Layer**: Create REST endpoints and DTOs
4. **Testing**: Full test coverage with unit and integration tests

## Instructions for Claude

When starting orchestration for a domain:

1. **Identify Domain**:
   ```bash
   # List all available domains
   find src/test/resources/features -type d -mindepth 1 -maxdepth 1 | xargs -n1 basename

   # Check if orchestrator exists
   ls orchestration-framework/orchestrate-*.sh
   ```

2. **Check Status**: Use commands above with your specific domain name

3. **Start/Resume**:
   - If orchestrator exists: `./orchestration-framework/orchestrate-<DOMAIN>.sh`
   - If not: Generate one with `./orchestration-framework/generate-orchestrator.sh <DOMAIN>`

4. **Monitor Progress**: Use the monitoring scripts with your domain name

5. **Direct Engineers**: Send specific tasks based on TODO files

Remember:
- Replace `<DOMAIN>` with actual domain name
- The goal is to implement all features following hexagonal architecture
- Each domain follows the pattern: `<DOMAIN>-dev` for session names