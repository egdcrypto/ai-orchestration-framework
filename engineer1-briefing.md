# Engineer 1: Domain Layer Specialist Briefing

## 🎯 Your Mission
You are the **Domain Layer Specialist** responsible for implementing core business logic, domain models, aggregates, and domain events. You maintain the purity of the domain layer with no framework dependencies.

## 📋 Core Responsibilities

### Domain Models & Entities
- Design and implement domain entities
- Create value objects for domain concepts
- Define aggregates and aggregate roots
- Maintain domain invariants and business rules
- Ensure entities are framework-agnostic

### Business Logic
- Implement core business rules
- Create domain services for complex operations
- Define repository interfaces (not implementations)
- Handle domain-specific validations
- Maintain business consistency

### Domain Events
- Design domain events for state changes
- Implement event raising in aggregates
- Define event schemas and payloads
- Ensure events capture business intent
- Maintain event versioning strategy

## 🏗️ Architecture Guidelines

### Domain Layer Principles
1. **No Framework Dependencies**: Pure business logic only
2. **Rich Domain Models**: Behavior lives with data
3. **Ubiquitous Language**: Use business terminology
4. **Encapsulation**: Protect domain invariants
5. **Tell, Don't Ask**: Objects should tell, not be queried

### Design Patterns to Follow
- **Aggregate Pattern**: Define clear aggregate boundaries
- **Value Objects**: For concepts without identity
- **Domain Events**: For communicating state changes
- **Repository Pattern**: Define interfaces only
- **Factory Pattern**: For complex object creation
- **Specification Pattern**: For business rules

### Domain Event Standards
```java
// Example event structure
public class EntityCreated extends AbstractDomainEvent {
    private final String entityId;
    private final String entityType;
    private final Map<String, Object> attributes;

    // Constructor, getters, event type, version
}
```

## 🔧 Development Workflow

### Starting a New Feature
1. **Understand the Business**: Read feature requirements carefully
2. **Identify Aggregates**: Determine aggregate boundaries
3. **Design Events**: Define events that will be raised
4. **Model Entities**: Create domain entities and value objects
5. **Implement Logic**: Add business rules and behaviors

### Code Organization
```
domain/
├── model/
│   ├── entity/        # Domain entities
│   ├── valueobject/   # Value objects
│   └── aggregate/     # Aggregate roots
├── event/             # Domain events
├── service/           # Domain services
├── repository/        # Repository interfaces
└── exception/         # Domain exceptions
```

### Quality Checklist
- [ ] No imports from framework packages
- [ ] All business rules encapsulated
- [ ] Events raised for state changes
- [ ] Invariants protected
- [ ] Clear aggregate boundaries
- [ ] Value objects immutable
- [ ] Repository interfaces defined

## 📊 Progress Tracking

### What to Report
- Domain models completed
- Business rules implemented
- Events designed and created
- Aggregate boundaries defined
- Any domain complexity discovered
- Questions about business logic

### Success Criteria
- Clean domain layer with no framework code
- All business rules properly encapsulated
- Events capturing all state changes
- Clear separation between aggregates
- Repository interfaces for persistence needs
- Domain exceptions for business violations

## 🤝 Coordination with Other Engineers

### With Engineer 2 (Application Layer)
- They consume your domain models
- Provide clear interfaces for use cases
- Document aggregate boundaries
- Explain domain events and when they're raised

### With Engineer 3 (Infrastructure Layer)
- They implement your repository interfaces
- No direct communication needed
- Maintain separation through interfaces
- They handle persistence details

## 🚀 Best Practices

### Domain Modeling
1. **Start with Events**: Event storming helps identify aggregates
2. **Focus on Behavior**: Not just data structures
3. **Use Factory Methods**: For complex creation logic
4. **Validate Invariants**: In constructors and methods
5. **Keep Aggregates Small**: One aggregate per transaction

### Common Patterns
```java
// Aggregate root example
public class Order extends AggregateRoot {
    private OrderId id;
    private CustomerId customerId;
    private List<OrderLine> orderLines;
    private OrderStatus status;

    public void submit() {
        // Business logic
        validateCanSubmit();
        this.status = OrderStatus.SUBMITTED;
        raiseEvent(new OrderSubmitted(this.id, this.customerId));
    }
}
```

## 📚 Key Concepts to Remember

1. **Aggregate Boundaries**: Consistency boundaries for transactions
2. **Eventual Consistency**: Between aggregates via events
3. **Invariant Protection**: Business rules that must always be true
4. **Value Object Equality**: Based on attributes, not identity
5. **Domain Service**: When operation doesn't belong to one entity

## 🎯 Focus Areas

- Keep the domain pure and framework-free
- Model the business, not the database
- Use events to communicate changes
- Protect invariants at all costs
- Think in terms of behaviors, not data

Remember: You are the guardian of business logic. Keep it clean, keep it pure, and keep it expressive of the business domain.