# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an AI Orchestration Framework that enables parallel execution of multiple Claude instances (called "engineers") through tmux sessions. The framework coordinates AI engineers working on different architectural layers simultaneously, following hexagonal architecture principles.

## Core Commands

### Starting Orchestration
```bash
# Copy and configure engineers
cp engineers.yaml.example engineers.yaml
# Edit engineers.yaml to define your team

# Start orchestration
./orchestrator.sh engineers.yaml start

# Alternative: Generate domain-specific orchestrator from Gherkin features
./generate-orchestrator.sh <domain-name>
```

### Monitoring and Management
```bash
# Check orchestration status
./orchestrator.sh engineers.yaml status

# Monitor all engineers in real-time
./orchestrator.sh engineers.yaml monitor
./monitor-engineers.sh <session-name>

# Check progress dashboard
./check-progress.sh <session-name>

# View detailed implementation progress
./monitor-implementation.sh <domain>

# See what each engineer is working on
./show-engineer-work.sh <session-name>
```

### Communication
```bash
# Send message to specific engineer
./send-message.sh <session-name>:<window-id> "Your message"

# Broadcast to all engineers
./orchestrator.sh engineers.yaml broadcast "Status update please"
./broadcast-message.sh <session-name> "Your message"

# List active engineers
./list-engineers.sh <session-name>
```

### Stopping Orchestration
```bash
./orchestrator.sh engineers.yaml stop
```

## Architecture

The framework enforces hexagonal architecture with three main layers:

1. **Domain Layer** (`domain/`)
   - Pure business logic, entities, value objects, domain events
   - No framework dependencies or annotations
   - Repository interfaces only (no implementations)

2. **Application Layer** (`application/`)
   - Application services orchestrating use cases
   - DTOs for data transfer
   - Transaction boundaries
   - No business logic, only orchestration

3. **Infrastructure Layer** (`infrastructure/`)
   - REST API endpoints
   - Repository implementations
   - External integrations
   - Framework configurations

## Configuration Structure

Engineers are configured via YAML files (see `engineers.yaml.example`):
- Define engineer IDs, names, roles, and briefings
- Specify coordination settings (communication method, check intervals)
- Configure build/test commands
- Set up optional notifications (Slack, Discord, Teams)

## tmux Session Layout

When orchestration starts:
- **Window 0**: Orchestrator (monitoring & coordination)
- **Window 1**: Domain Engineer (business logic & models)
- **Window 2**: Application Engineer (services & DTOs)
- **Window 3**: Infrastructure Engineer (APIs & controllers)
- Additional windows for extra engineers if configured

## Build and Test Commands

The framework assumes Gradle by default but supports any build system. Configure in `engineers.yaml`:
- Build: `./gradlew build` (default)
- Test: `./gradlew test` (default)

To verify build status during orchestration:
```bash
./gradlew build --quiet
```

## Key Scripts

- `orchestrator.sh`: Main orchestration system with all features
- `generate-orchestrator.sh`: Generate domain-specific orchestrators from Gherkin
- `continuous-orchestration.sh`: Automated orchestration loop
- `check-alerts.sh`: Monitor for stuck engineers
- `setup-notifications.sh`: Configure webhook notifications

## Working with Engineers

Each engineer operates independently but coordinates through:
- TODO files in `/tmp/<session>_todos/`
- Progress logs in `/tmp/<session>_progress/`
- Briefings stored in `/tmp/<session>_briefings/`

Engineers automatically receive clarifying prompts if they become stuck or inactive.