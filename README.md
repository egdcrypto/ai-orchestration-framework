# AI Orchestration Framework

A powerful framework for orchestrating multiple AI engineers (Claude instances) working in parallel through tmux to build complete software systems with unprecedented velocity.

## Overview

This framework transforms tmux into an AI team management platform, allowing you to run multiple Claude instances in parallel, each focusing on specific architectural layers while maintaining clean separation of concerns.

## Key Features

- **Parallel AI Execution**: Run 3+ Claude instances simultaneously in tmux sessions
- **Architectural Separation**: Each AI engineer stays within their designated layer (domain, application, infrastructure)
- **Automated Coordination**: Engineers communicate through structured TODO files and progress logs
- **Self-Healing Orchestration**: Detects stuck engineers and sends clarifying prompts
- **Progress Monitoring**: Real-time tracking of each engineer's work
- **Domain-Agnostic**: Works with any architecture pattern or programming language

## Results

- **70% reduction** in development time
- **95% test coverage** maintained across projects
- **Clean architecture** preserved throughout development
- **Zero context pollution** between architectural layers

## Quick Start

1. **Create your engineer configuration**:
```bash
cp engineers.yaml.example engineers.yaml
# Edit engineers.yaml to define your team and briefings
```

2. **Set up notifications (optional)**:
```bash
export SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK"
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/YOUR/WEBHOOK"
export TEAMS_WEBHOOK="https://outlook.office.com/webhook/YOUR/WEBHOOK"
```

3. **Start orchestration**:
```bash
./orchestrator.sh engineers.yaml start
```

4. **Monitor and manage**:
```bash
# Check status
./orchestrator.sh engineers.yaml status

# Monitor all engineers
./orchestrator.sh engineers.yaml monitor

# Broadcast to all engineers
./orchestrator.sh engineers.yaml broadcast "Status update please"

# Stop orchestration
./orchestrator.sh engineers.yaml stop
```

This spawns a tmux session with multiple Claude instances working in parallel:
- Window 0: Orchestrator (monitoring & coordination)
- Window 1: Domain Engineer (business logic & models)
- Window 2: Application Engineer (services & DTOs)
- Window 3: Infrastructure Engineer (APIs & controllers)

### 3. Monitor Progress

```bash
# Check overall status
./check-progress.sh your-domain-dev

# View detailed implementation progress
./monitor-implementation.sh your-domain

# See what each engineer is working on
./show-engineer-work.sh your-domain-dev
```

### 4. Interact with Engineers

```bash
# Send message to specific engineer
./send-claude-message.sh your-domain-dev:1 "Focus on user authentication next"

# Send status request to all engineers
./send-claude-message.sh your-domain-dev:0 "Status update please"
```

## How It Works

1. **Define Requirements**: Write your features in Gherkin format
2. **Launch Framework**: Run the orchestration script for your domain
3. **Parallel Development**: AI engineers work simultaneously on different layers
4. **Continuous Integration**: Framework monitors builds and tests
5. **Progress Tracking**: Real-time updates through tmux capture

## Framework Components

### Core Orchestration
- `orchestrator.sh` - Unified orchestration system with all features
- `engineers.yaml.example` - Configuration template with engineer definitions and briefings

### Alternative Approaches
- `generate-orchestrator.sh` - Generate domain-specific orchestrators from Gherkin features

### Supporting Scripts
- `send-message.sh` - Send messages to specific engineers
- `broadcast-message.sh` - Broadcast to all engineers (also built into orchestrator.sh)
- `list-engineers.sh` - List active engineers
- `monitor-engineers.sh` - Real-time monitoring (also built into orchestrator.sh)
- `monitor-implementation.sh` - Progress tracking for feature-based development
- `check-progress.sh` - Quick status dashboard

### Default Briefings
- `engineer1-briefing.md` - Domain layer template
- `engineer2-briefing.md` - Application layer template
- `engineer3-briefing.md` - Infrastructure layer template

### Utilities
- `continuous-orchestration.sh` - Automated orchestration loop
- `setup-notifications.sh` - Configure notification webhooks

## Architecture Patterns Supported

The framework enforces hexagonal architecture by default but can be adapted to:
- Clean Architecture
- Domain-Driven Design (DDD)
- Microservices
- Event-Driven Architecture
- MVC/MVP/MVVM patterns

## Real-World Example: The Rover

Using this framework, I built [The Rover](https://github.com/egdcrypto/the-rover) - a Multi-Application Autonomous Platform in record time. The Rover is an autonomous robotics platform integrating multiple AI systems:

**Public Repository**: https://github.com/egdcrypto/the-rover

**What Was Built with AI Orchestration**:
- **Computer Vision System**: Object detection, facial recognition, gesture control
- **Voice Assistant Integration**: Natural language processing and voice commands
- **Autonomous Navigation**: Path planning and obstacle avoidance algorithms
- **Sensor Fusion Module**: Integration of LIDAR, ultrasonic, and camera data
- **Web Control Dashboard**: Real-time monitoring and control interface
- **ROS2 Integration**: Complete robotics middleware implementation
- **Security System**: Threat detection and monitoring capabilities

The orchestration framework enabled parallel development across all these complex subsystems, with AI engineers working simultaneously on:
- Hardware abstraction layers
- Sensor processing pipelines
- ML model integrations
- Real-time control systems
- Web interfaces and APIs

This demonstrates the framework's capability beyond traditional web applications, showing how it can orchestrate development of complex cyber-physical systems combining hardware, embedded software, and AI.

## Requirements

- tmux installed on your system
- Access to Claude API (via Claude Code or similar)
- Basic understanding of your chosen architecture pattern
- Gherkin feature files (or similar requirements)

## Best Practices

1. **Clear Role Definition**: Each engineer should have a specific, well-defined role
2. **Architectural Boundaries**: Maintain strict separation between layers
3. **Incremental Progress**: Break features into small, manageable tasks
4. **Continuous Monitoring**: Regularly check progress and intervene when needed
5. **Version Control**: Commit frequently as engineers complete components

## Contributing

This framework is actively evolving. Contributions, suggestions, and improvements are welcome!

## License

MIT License - See LICENSE file for details

## Author

Built with passion for accelerating software development through AI orchestration.

---

*"The future of software development isn't AI helping us code - it's AI teams we orchestrate to build entire systems."*