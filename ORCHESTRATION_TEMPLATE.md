# Feature Implementation Orchestration Template

## Overview
This template provides a repeatable process for orchestrating AI engineers to implement any feature defined in Gherkin files.

**CRITICAL**: All implementations MUST follow Hexagonal Architecture. See [HEXAGONAL_ARCHITECTURE_GUIDE.md](./HEXAGONAL_ARCHITECTURE_GUIDE.md) for detailed patterns and rules.

## Pre-Orchestration Checklist

### 1. Feature Analysis
- [ ] Identify target feature directory: `src/test/resources/features/{domain}/`
- [ ] Count number of .feature files in domain
- [ ] Estimate complexity (Simple: 1-3 files, Medium: 4-6 files, Complex: 7+ files)
- [ ] Check for existing implementation in codebase

### 2. Create Feature Metadata
```bash
# Create feature implementation directory
mkdir -p src/test/resources/features/{domain}/implementation
cd src/test/resources/features/{domain}/implementation

# Create tracking files for each feature
for feature in ../*.feature; do
    base=$(basename "$feature" .feature)
    touch "${base}_TODO.md"
    touch "${base}_LOG.md"
done

# Create overall progress tracker
cat > IMPLEMENTATION_PROGRESS.md << EOF
# ${DOMAIN} Implementation Progress

## Overview
Tracking implementation of ${DOMAIN} features.

## Feature Status
$(ls ../*.feature | while read f; do echo "- [ ] $(basename $f)"; done)

## Team Assignment
- Engineer 1 (API): TBD
- Engineer 2 (Domain): TBD  
- Engineer 3 (Testing): TBD
EOF
```

### 3. Generate TODO Files
For each feature file, create a TODO.md with this structure:

```markdown
# {Feature} Implementation TODO

## Analysis Date: $(date)
## Feature File: {feature}.feature
## Status: NOT_STARTED

## Implementation Checklist

### 1. Domain Layer (com.yourcompany.domain)
- [ ] Review existing domain models in domain/entity/
- [ ] Create/update aggregates extending AggregateRoot if needed
- [ ] Define domain events extending AbstractDomainEvent
- [ ] Implement business rules - NO framework dependencies!
- [ ] ⚠️ Domain entities NEVER import DTOs or infrastructure classes

### 2. Application Layer (com.yourcompany.application)
- [ ] Create use case interfaces in application/usecase/
- [ ] Implement application services in application/service/
- [ ] Transform between Domain objects ↔ DTOs
- [ ] Handle orchestration logic and workflow coordination
- [ ] ⚠️ Services return DTOs to controllers, work with domain internally

### 3. Infrastructure Layer (com.yourcompany.infrastructure)
- [ ] Create REST controllers in infrastructure/adapter/in/web/rest/
- [ ] Create request DTOs in infrastructure/adapter/in/web/rest/dto/request/
- [ ] Create response DTOs in infrastructure/adapter/in/web/rest/dto/response/
- [ ] Use ApiResponse wrapper from infrastructure.adapter.in.web.rest.dto.ApiResponse
- [ ] Implement repository adapters in infrastructure/adapter/out/persistence/
- [ ] ⚠️ Controllers ONLY call application services, never domain directly

### 4. Testing
- [ ] Write unit tests
- [ ] Create integration tests
- [ ] Implement Cucumber step definitions
- [ ] Verify >80% coverage

### 5. Documentation
- [ ] Update API documentation
- [ ] Add Swagger annotations
- [ ] Create usage examples
- [ ] Update README
```

## Orchestration Script Template

```bash
#!/bin/bash
# orchestrate-{domain}.sh

DOMAIN="{domain}"
SESSION_NAME="${DOMAIN}-dev"
PROJECT_ROOT="${PROJECT_ROOT}"
FEATURE_DIR="src/test/resources/features/${DOMAIN}"

# Create session
tmux new-session -d -s $SESSION_NAME -c $PROJECT_ROOT

# Window 0: Project Manager
tmux rename-window -t $SESSION_NAME:0 'PM-Orchestrator'
tmux send-keys -t $SESSION_NAME:0 "echo '🎯 ${DOMAIN} Feature Implementation'" Enter
tmux send-keys -t $SESSION_NAME:0 "echo 'Feature Directory: ${FEATURE_DIR}'" Enter
tmux send-keys -t $SESSION_NAME:0 "ls -la ${FEATURE_DIR}/*.feature" Enter

# Window 1: API Engineer
tmux new-window -t $SESSION_NAME -n 'Engineer1-API' -c $PROJECT_ROOT
tmux send-keys -t $SESSION_NAME:1 "claude --dangerously-skip-permissions" Enter
sleep 5

# Window 2: Domain Engineer  
tmux new-window -t $SESSION_NAME -n 'Engineer2-Domain' -c $PROJECT_ROOT
tmux send-keys -t $SESSION_NAME:2 "claude --dangerously-skip-permissions" Enter
sleep 5

# Window 3: Testing Engineer
tmux new-window -t $SESSION_NAME -n 'Engineer3-Testing' -c $PROJECT_ROOT
tmux send-keys -t $SESSION_NAME:3 "claude --dangerously-skip-permissions" Enter
sleep 5

# Window 4: Build Monitor
tmux new-window -t $SESSION_NAME -n 'Build-Monitor' -c $PROJECT_ROOT/backend
tmux send-keys -t $SESSION_NAME:4 "watch -n 30 './gradlew build --quiet && echo BUILD_SUCCESS || echo BUILD_FAILED'" Enter

# Window 5: Git Backup
tmux new-window -t $SESSION_NAME -n 'Git-Backup' -c $PROJECT_ROOT
# ... (git backup loop)

echo "✅ Session created. Sending engineer briefings..."
```

## Engineer Briefing Templates

### Engineer 1 - API Specialist
```
You are Engineer 1: API Specialist for ${DOMAIN} features.

Your mission: Implement REST controllers and API endpoints.

IMPORTANT FIRST STEPS:
1. Navigate to src/test/resources/features/${DOMAIN}/
2. List all files to understand what's available
3. Look for any existing progress tracking files (PROGRESS.md, ANALYSIS.md)
4. For each feature you work on:
   - Read the .feature file for API specifications
   - Check if a _TODO.md file exists with specific tasks
   - Create/update _LOG.md files to track your progress

DO NOT rely on file paths provided in this message - always explore and verify!

Key principles:
- Follow hexagonal architecture patterns:
  * Controllers (infrastructure) → Services (application) → Domain
  * DTOs only in infrastructure layer
  * Domain has NO dependencies on infrastructure
  * Services transform between domain and DTOs
- Use existing patterns: ExampleController + ExampleApplicationService
- Import ApiResponse from infrastructure.adapter.in.web.rest.dto.ApiResponse
- Test each endpoint before moving to next
- Document your progress in LOG files
```

### Engineer 2 - Domain Specialist
```
You are Engineer 2: Domain Logic Specialist for ${DOMAIN} features.

Your mission: Implement domain models and business logic.

📁 Feature Files: ${FEATURE_DIR}/*.feature
📝 TODO Files: ${FEATURE_DIR}/implementation/*_TODO.md
📊 Progress: ${FEATURE_DIR}/implementation/*_LOG.md

Instructions:
1. Analyze feature files for domain requirements
2. Create/update domain aggregates
3. Implement domain events
4. Build application services
5. Ensure business rules are enforced

Start by mapping feature requirements to domain concepts.
```

### Engineer 3 - Testing Specialist  
```
You are Engineer 3: Testing Specialist for ${DOMAIN} features.

Your mission: Implement comprehensive test coverage.

📁 Feature Files: ${FEATURE_DIR}/*.feature
📝 TODO Files: ${FEATURE_DIR}/implementation/*_TODO.md
📊 Progress: ${FEATURE_DIR}/implementation/*_LOG.md

Instructions:
1. Create Cucumber step definitions for each scenario
2. Write unit tests for all new code
3. Build integration test fixtures
4. Ensure >80% test coverage
5. Verify all scenarios pass

Start by implementing step definitions for the first feature file.
```

## Progress Monitoring Script

```bash
#!/bin/bash
# monitor-{domain}-progress.sh

DOMAIN="{domain}"
SESSION_NAME="${DOMAIN}-dev"
FEATURE_DIR="src/test/resources/features/${DOMAIN}/implementation"

echo "📊 ${DOMAIN} Implementation Progress"
echo "Time: $(date)"
echo ""

# Check TODO completion
echo "📋 TODO Status:"
for todo in $FEATURE_DIR/*_TODO.md; do
    feature=$(basename "$todo" _TODO.md)
    total=$(grep -c "^- \[ \]" "$todo" 2>/dev/null || echo 0)
    done=$(grep -c "^- \[x\]" "$todo" 2>/dev/null || echo 0)
    echo "  $feature: $done/$total tasks complete"
done

# Check recent LOG entries
echo ""
echo "📝 Recent Progress:"
for log in $FEATURE_DIR/*_LOG.md; do
    if [ -f "$log" ]; then
        echo "  $(basename $log):"
        tail -5 "$log" | sed 's/^/    /'
    fi
done

# Check build status
echo ""
echo "🔨 Build Status:"
cd backend && ./gradlew build --quiet && echo "  ✅ BUILD PASSING" || echo "  ❌ BUILD FAILING"
```

## Implementation Patterns

### 1. Feature Grouping Strategy
Group features by:
- **Complexity**: Simple features to one engineer, complex to multiple
- **Dependencies**: Related features to same engineer
- **Layer**: API features to Engineer 1, domain to Engineer 2

### 2. Task Distribution
```yaml
Engineer 1 (API):
  - REST controllers
  - Request/response DTOs
  - API documentation
  - Security configuration

Engineer 2 (Domain):
  - Domain models
  - Business logic
  - Application services
  - Domain events

Engineer 3 (Testing):
  - Cucumber step definitions
  - Unit tests
  - Integration tests
  - Test fixtures
```

### 3. Communication Protocol
```bash
# Status check every 2 hours
./send-claude-message.sh ${SESSION}:${WINDOW} "STATUS_CHECK: Please update your LOG files and report blockers"

# Cross-engineer coordination
./send-claude-message.sh ${SESSION}:1 "COORD: Engineer 2 has completed domain model for Feature X"
```

## Reusable Components

### 1. Feature Analyzer Script
```bash
#!/bin/bash
# analyze-feature.sh
FEATURE_FILE=$1

echo "Analyzing $FEATURE_FILE"
echo "Scenarios: $(grep -c "Scenario:" $FEATURE_FILE)"
echo "Given statements: $(grep -c "Given" $FEATURE_FILE)"
echo "API endpoints: $(grep -oE "(GET|POST|PUT|DELETE) /api/[^ ]*" $FEATURE_FILE | sort -u)"
echo "Domain entities: $(grep -oE "entity\".*:.*\"([^\"]+)\"" $FEATURE_FILE | cut -d'"' -f4 | sort -u)"
```

### 2. Progress Dashboard
```bash
#!/bin/bash
# dashboard.sh
watch -n 10 '
clear
echo "=== Implementation Dashboard ==="
echo "Session: $SESSION_NAME"
echo "Time: $(date)"
echo ""
echo "=== Engineer Status ==="
for i in 1 2 3; do
    echo "Engineer $i: $(tmux capture-pane -t $SESSION_NAME:$i -p | tail -1)"
done
echo ""
echo "=== Build Status ==="
cd backend && timeout 5 ./gradlew build --quiet && echo "✅ PASSING" || echo "❌ FAILING"
echo ""
echo "=== Git Status ==="
git status --short
'
```

## Success Metrics

1. **Implementation Velocity**
   - Features completed per day
   - Time from start to first passing test
   - Blockers encountered and resolved

2. **Quality Metrics**
   - Test coverage percentage
   - Build success rate
   - Code review findings

3. **Progress Tracking**
   - TODO items completed
   - LOG entries per engineer
   - Feature completion percentage

## Scaling Guidelines

### Small Domain (1-3 features)
- 1 engineer can handle all layers
- 2-3 day timeline
- Single tmux session

### Medium Domain (4-6 features)
- 2-3 engineers with specialization
- 1 week timeline
- Progress checks twice daily

### Large Domain (7+ features)
- Full 3-engineer team
- 2+ week timeline
- Daily standups
- Consider multiple sessions

## Troubleshooting

### Common Issues
1. **Engineers stuck on task**
   - Check LOG file for last entry
   - Send clarification message
   - Provide example from similar feature

2. **Build failures**
   - Check build window output
   - Direct engineer to fix immediately
   - Pause new development until green

3. **Merge conflicts**
   - Use feature branches
   - Coordinate through PM window
   - Regular rebasing

## Continuous Improvement

After each domain implementation:
1. Review what worked well
2. Identify bottlenecks
3. Update templates with learnings
4. Share patterns across teams

This framework ensures consistent, efficient implementation of any feature domain in the codebase.