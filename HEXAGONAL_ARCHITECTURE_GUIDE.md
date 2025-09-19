# Hexagonal Architecture Guide

## Overview
This guide describes how to implement Hexagonal Architecture (Ports & Adapters) pattern. Every engineer must understand and follow these patterns.

## Architecture Layers

### 1. Domain Layer

**Purpose**: Core business logic, pure domain models, business rules

**Location**: `src/main/java/com/yourcompany/domain/`

**Contents**:
- **Entities**: `domain/entity/` (e.g., Order, Customer, Product)
- **Value Objects**: `domain/valueobject/` (e.g., Money, Address, Status)
- **Domain Events**: `domain/event/` (extend AbstractDomainEvent)
- **Aggregates**: Extend `AggregateRoot` for event sourcing
- **Domain Services**: Pure business logic services

**Rules**:
- ❌ NO framework annotations (except @Entity for JPA if needed)
- ❌ NO imports from infrastructure or application layers
- ❌ NO DTOs, Controllers, or framework-specific code
- ✅ Pure language/business logic only
- ✅ Rich domain models with behavior

**Example**:
```java
package com.yourcompany.domain.entity;

public class Order extends BaseEntity {
    private CustomerId customerId;
    private List<OrderLine> orderLines;
    private OrderStatus status;

    // Business logic methods
    public void submit() {
        validateCanSubmit();
        this.status = OrderStatus.SUBMITTED;
        raiseEvent(new OrderSubmittedEvent(this.id));
    }
}
```

### 2. Application Layer

**Purpose**: Use cases, orchestration, coordination between domain and infrastructure

**Location**: `src/main/java/com/yourcompany/application/`

**Contents**:
- **Application Services**: `application/service/` (e.g., OrderApplicationService)
- **Use Case Interfaces**: `application/usecase/`
- **Command/Query Objects**: `application/command/`, `application/query/`
- **Port Interfaces**: Define contracts for infrastructure

**Rules**:
- ✅ Transform DTOs ↔ Domain Objects
- ✅ Orchestrate domain logic
- ✅ Transaction boundaries
- ✅ Can use framework annotations (@Service, @Transactional)
- ❌ NO business rules (those belong in domain)
- ❌ NO direct infrastructure dependencies (use interfaces)

**Example**:
```java
package com.yourcompany.application.service;

@Service
@RequiredArgsConstructor
public class OrderApplicationService {
    private final OrderRepository repository;
    private final PaymentService paymentService;

    public OrderResponse createOrder(CreateOrderRequest request) {
        // 1. Create domain entity
        Order order = Order.create(request.getCustomerId(), request.getItems());

        // 2. Execute domain logic
        order.submit();

        // 3. Persist
        repository.save(order);

        // 4. Transform to DTO and return
        return OrderResponse.fromEntity(order);
    }
}
```

### 3. Infrastructure Layer

**Purpose**: External interfaces, frameworks, databases, web layer

**Location**: `src/main/java/com/yourcompany/infrastructure/`

**Structure**:
```
infrastructure/
├── adapter/
│   ├── in/           # Inbound adapters (driving)
│   │   └── web/
│   │       └── rest/
│   │           ├── OrderController.java
│   │           └── dto/
│   │               ├── ApiResponse.java
│   │               ├── request/
│   │               │   └── CreateOrderRequest.java
│   │               └── response/
│   │                   └── OrderResponse.java
│   └── out/          # Outbound adapters (driven)
│       ├── persistence/
│       │   └── JpaOrderRepository.java
│       └── messaging/
│           └── EventPublisher.java
```

**Rules**:
- ✅ All DTOs here (request/response)
- ✅ Controllers, REST endpoints
- ✅ Repository implementations
- ✅ External service clients
- ✅ Framework-specific code
- ❌ NO business logic
- ❌ Controllers ONLY call application services

**Example Controller**:
```java
package com.yourcompany.infrastructure.adapter.in.web.rest;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderApplicationService orderService;

    @PostMapping
    public ResponseEntity<ApiResponse<OrderResponse>> createOrder(
            @Valid @RequestBody CreateOrderRequest request) {

        // ONLY calls application service
        OrderResponse result = orderService.createOrder(request);

        return ResponseEntity.ok(ApiResponse.success("Order created", result));
    }
}
```

## Data Flow

```
HTTP Request → Controller (Infrastructure)
    → Application Service (Application)
        → Domain Logic (Domain)
        → Repository Interface (Domain)
    ← Repository Implementation (Infrastructure)
← Response DTO (Infrastructure)
```

## Common Patterns

### 1. DTO to Domain Transformation
```java
// In Application Service
public OrderResponse updateOrder(UpdateOrderRequest request) {
    // DTO → Domain
    Order order = repository.findById(request.getId());
    order.updateShippingAddress(request.getAddress());

    // Save domain
    repository.save(order);

    // Domain → DTO
    return OrderResponse.fromEntity(order);
}
```

### 2. ApiResponse Wrapper
Always use the standard ApiResponse wrapper:
```java
import com.yourcompany.infrastructure.adapter.in.web.rest.dto.ApiResponse;

return ResponseEntity.ok(ApiResponse.success("Success message", data));
return ResponseEntity.badRequest().body(ApiResponse.error("ERROR_CODE", "Error message"));
```

### 3. Domain Events
```java
// In Domain Entity
public class Order extends AggregateRoot {
    public void complete() {
        this.status = OrderStatus.COMPLETED;
        raiseEvent(new OrderCompletedEvent(this.id, this.customerId));
    }
}
```

## Testing Strategy

### Unit Tests
- **Domain**: Test business logic in isolation
- **Application**: Mock repositories, test orchestration
- **Infrastructure**: Mock application services, test HTTP layer

### Integration Tests
- Test full flow through all layers
- Use real framework context
- Test through REST endpoints

## Common Mistakes to Avoid

1. ❌ **Importing DTOs in Domain**
```java
// WRONG
public class Order {
    public OrderResponse toResponse() { } // Domain shouldn't know about DTOs
}
```

2. ❌ **Business Logic in Controllers**
```java
// WRONG
@RestController
public class Controller {
    public void processOrder(String id) {
        if (order.getTotal() < 100) { // Business rule in controller!
            throw new Exception();
        }
    }
}
```

3. ❌ **Skipping Application Layer**
```java
// WRONG
@RestController
public class Controller {
    @Autowired
    private OrderRepository repository; // Controller directly using repository!
}
```

4. ❌ **Wrong Package Structure**
```java
// WRONG
com.yourcompany.dto.OrderDTO // DTOs at root level
com.yourcompany.service.OrderService // Mixed layers

// CORRECT
com.yourcompany.infrastructure.adapter.in.web.rest.dto.response.OrderResponse
com.yourcompany.application.service.OrderApplicationService
```

## Quick Reference

| Layer | Package | Can Import | Cannot Import | Framework Annotations |
|-------|---------|------------|---------------|-------------------|
| Domain | `.domain` | Other domain | Application, Infrastructure | None (except @Entity) |
| Application | `.application` | Domain | Infrastructure (only interfaces) | @Service, @Transactional |
| Infrastructure | `.infrastructure` | Domain, Application | - | @RestController, @Repository, etc |

## Checking Your Implementation

Ask yourself:
1. Can I unit test my domain logic without frameworks?
2. Are my DTOs only in the infrastructure layer?
3. Do my controllers only call application services?
4. Are business rules in domain entities, not services?
5. Can I swap my REST API for GraphQL without changing domain/application?

If you answer "no" to any of these, you're violating hexagonal architecture!

## Examples to Follow

- **Good Reference**: `OrderController` + `OrderApplicationService` + `OrderEntity`
- **Domain Events**: `AbstractDomainEvent` and implementations
- **DTOs**: Check `infrastructure/adapter/in/web/rest/dto/` structure

Remember: The architecture ensures our business logic remains independent of frameworks and external concerns!