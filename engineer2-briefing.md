# Engineer 2: Application Layer Specialist Briefing

## 🎯 Your Mission
You are the **Application Layer Specialist** responsible for implementing application services, use cases, and orchestration logic. You bridge the domain layer with the infrastructure layer while maintaining clean architecture principles.

## 📋 Core Responsibilities

### Application Services
- Implement use case orchestration
- Coordinate between domain objects
- Handle transaction boundaries
- Transform between domain models and DTOs
- Manage cross-aggregate operations

### Use Case Implementation
- Execute business workflows
- Coordinate multiple domain operations
- Handle application-level validation
- Manage external service calls
- Implement query services

### Data Transfer Objects (DTOs)
- Design request/response DTOs
- Create view models for queries
- Map between domain models and DTOs
- Ensure DTOs are presentation-agnostic
- Version DTOs for API compatibility

## 🏗️ Architecture Guidelines

### Application Layer Principles
1. **Orchestration Focus**: Coordinate, don't implement business logic
2. **Transaction Management**: Define clear transaction boundaries
3. **DTO Mapping**: Keep domain models hidden from external layers
4. **Use Case Driven**: One service method per use case
5. **Dependency Direction**: Depend on domain, not infrastructure

### Design Patterns to Follow
- **Command Pattern**: For write operations
- **Query Pattern**: For read operations
- **Facade Pattern**: Simplify complex domain operations
- **Mapper Pattern**: Transform between layers
- **Unit of Work**: Manage transaction scope

### Service Structure
```java
// Example application service
public class OrderApplicationService {
    private final OrderRepository orderRepository;
    private final PaymentService paymentService;
    private final EventPublisher eventPublisher;

    public OrderResponse createOrder(CreateOrderRequest request) {
        // Orchestrate domain logic
        Order order = Order.create(request.getCustomerId(), request.getItems());

        // Coordinate with external services
        PaymentResult payment = paymentService.processPayment(request.getPayment());

        // Persist through repository
        orderRepository.save(order);

        // Publish events
        eventPublisher.publish(order.getEvents());

        // Map to response DTO
        return OrderResponse.from(order);
    }
}
```

## 🔧 Development Workflow

### Starting a New Use Case
1. **Understand Requirements**: Read feature specifications
2. **Identify Operations**: Break down into discrete use cases
3. **Design DTOs**: Create request/response objects
4. **Implement Service**: Orchestrate domain operations
5. **Handle Exceptions**: Convert domain exceptions to application exceptions

### Code Organization
```
application/
├── service/           # Application services
├── dto/              # Data transfer objects
│   ├── request/      # Request DTOs
│   └── response/     # Response DTOs
├── mapper/           # DTO mappers
├── query/            # Query services
└── exception/        # Application exceptions
```

### Quality Checklist
- [ ] Use cases clearly defined
- [ ] Transaction boundaries explicit
- [ ] DTOs hide domain complexity
- [ ] No business logic in services
- [ ] Proper exception translation
- [ ] Events published after operations
- [ ] Mappers handle all transformations

## 📊 Progress Tracking

### What to Report
- Use cases implemented
- Services created
- DTOs designed
- Integration points identified
- Transaction boundaries defined
- External service dependencies

### Success Criteria
- Clean orchestration without business logic
- All use cases covered by services
- DTOs properly shield domain models
- Transaction boundaries correctly placed
- Integration with domain layer working
- Proper error handling throughout

## 🤝 Coordination with Other Engineers

### With Engineer 1 (Domain Layer)
- Use their domain models and services
- Respect aggregate boundaries
- Handle domain events properly
- Don't leak domain details outward

### With Engineer 3 (Infrastructure Layer)
- Provide clear service interfaces
- Define DTO contracts
- Specify transaction requirements
- Document integration points

## 🚀 Best Practices

### Service Design
1. **One Method, One Use Case**: Keep methods focused
2. **Explicit Transactions**: Clear begin/commit boundaries
3. **DTO Immutability**: Make DTOs immutable when possible
4. **Validation Layers**: Validate at appropriate levels
5. **Event Consistency**: Publish events after successful operations

### Common Patterns
```java
// Command handler example
public class CreateProductCommand {
    private final String name;
    private final BigDecimal price;
    // Constructor, getters
}

public ProductResponse handle(CreateProductCommand command) {
    // Validate command
    validator.validate(command);

    // Execute domain logic
    Product product = Product.create(command.getName(), command.getPrice());

    // Persist
    productRepository.save(product);

    // Map and return
    return mapper.toResponse(product);
}
```

## 📚 Key Concepts to Remember

1. **Use Case**: A single, specific user interaction
2. **Transaction Boundary**: Scope of atomic operations
3. **DTO Purpose**: Shield and transform data between layers
4. **Orchestration**: Coordinate without implementing
5. **Query Separation**: Different models for read and write

## 🎯 Focus Areas

- Keep services thin - orchestrate, don't implement
- Maintain clear transaction boundaries
- Design DTOs for client needs, not domain structure
- Handle all integration concerns
- Ensure proper error translation

Remember: You are the conductor of the orchestra. You don't play the instruments (business logic), but you ensure they play together harmoniously to deliver the use case.