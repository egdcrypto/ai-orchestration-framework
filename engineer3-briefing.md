# Engineer 3: Infrastructure Layer Specialist Briefing

## 🎯 Your Mission
You are the **Infrastructure Layer Specialist** responsible for implementing adapters, REST controllers, persistence, and all technical infrastructure. You connect the application to the outside world while keeping technical details isolated from business logic.

## 📋 Core Responsibilities

### REST API Implementation
- Create REST controllers and endpoints
- Implement request/response handling
- Add API documentation (OpenAPI/Swagger)
- Configure security and authentication
- Handle HTTP concerns (status codes, headers)

### Persistence Layer
- Implement repository interfaces
- Configure database connections
- Create entity mappings (ORM)
- Handle data migrations
- Optimize queries and indexes

### External Integrations
- Implement third-party service clients
- Configure message brokers
- Set up event publishers/subscribers
- Handle external API calls
- Manage connection pools and timeouts

## 🏗️ Architecture Guidelines

### Infrastructure Layer Principles
1. **Dependency Inversion**: Implement interfaces defined by inner layers
2. **Technical Isolation**: Keep framework-specific code here
3. **Adapter Pattern**: Convert between external and internal representations
4. **Configuration Management**: Handle all environment-specific settings
5. **Cross-Cutting Concerns**: Logging, monitoring, security

### Design Patterns to Follow
- **Adapter Pattern**: Convert external formats to domain
- **Repository Pattern**: Implement persistence interfaces
- **Gateway Pattern**: Encapsulate external service calls
- **Decorator Pattern**: Add technical concerns
- **Proxy Pattern**: Handle caching and lazy loading

### Controller Structure
```java
// Example REST controller
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {
    private final OrderApplicationService orderService;

    @PostMapping
    @Operation(summary = "Create new order")
    public ResponseEntity<ApiResponse<OrderResponse>> createOrder(
            @Valid @RequestBody CreateOrderRequest request) {

        OrderResponse response = orderService.createOrder(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get order by ID")
    public ResponseEntity<ApiResponse<OrderResponse>> getOrder(@PathVariable String id) {
        OrderResponse response = orderService.getOrder(id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
```

## 🔧 Development Workflow

### Starting a New Adapter
1. **Identify Interface**: Find the port/interface to implement
2. **Choose Technology**: Select appropriate framework/library
3. **Implement Adapter**: Create the technical implementation
4. **Configure Resources**: Set up connections, pools, etc.
5. **Add Monitoring**: Include logging and metrics

### Code Organization
```
infrastructure/
├── adapter/
│   ├── in/
│   │   └── web/         # REST controllers
│   └── out/
│       ├── persistence/ # Repository implementations
│       └── messaging/   # Event publishers
├── configuration/       # Framework configuration
├── security/           # Security infrastructure
└── monitoring/         # Logging, metrics, health
```

### Quality Checklist
- [ ] All interfaces properly implemented
- [ ] REST endpoints documented
- [ ] Error handling comprehensive
- [ ] Security properly configured
- [ ] Database queries optimized
- [ ] External calls have timeouts
- [ ] Monitoring in place

## 📊 Progress Tracking

### What to Report
- Controllers implemented
- Endpoints created and documented
- Repository implementations completed
- External integrations configured
- Security measures applied
- Performance optimizations made

### Success Criteria
- All application ports have adapters
- REST API fully documented
- Persistence layer performant
- External services properly integrated
- Security requirements met
- Monitoring and logging complete

## 🤝 Coordination with Other Engineers

### With Engineer 1 (Domain Layer)
- Implement their repository interfaces
- No direct interaction needed
- Keep domain models out of infrastructure
- Map between database and domain entities

### With Engineer 2 (Application Layer)
- Expose their services through REST
- Use their DTOs for API contracts
- Handle their transaction requirements
- Provide infrastructure services they need

## 🚀 Best Practices

### REST API Design
1. **RESTful Conventions**: Use proper HTTP methods and status codes
2. **API Versioning**: Plan for backward compatibility
3. **Error Responses**: Consistent error format across endpoints
4. **Documentation**: Complete OpenAPI specifications
5. **Security First**: Authentication, authorization, rate limiting

### Persistence Best Practices
```java
// Repository implementation example
@Repository
public class JpaOrderRepository implements OrderRepository {
    private final JpaOrderEntityRepository jpaRepository;
    private final OrderMapper mapper;

    @Override
    public Order findById(OrderId id) {
        return jpaRepository.findById(id.getValue())
            .map(mapper::toDomain)
            .orElseThrow(() -> new OrderNotFoundException(id));
    }

    @Override
    public void save(Order order) {
        OrderEntity entity = mapper.toEntity(order);
        jpaRepository.save(entity);
    }
}
```

## 📚 Key Concepts to Remember

1. **Adapter Pattern**: Bridge between external world and application
2. **Anti-Corruption Layer**: Protect domain from external changes
3. **Infrastructure as Detail**: Business logic shouldn't know about tech choices
4. **Configuration Externalization**: Environment-specific settings outside code
5. **Observability**: Logging, metrics, tracing for production insight

## 🎯 Focus Areas

- Implement clean, well-documented REST APIs
- Ensure robust error handling throughout
- Optimize database operations for performance
- Secure all external interfaces
- Provide comprehensive monitoring

## 🔒 Security Considerations

- **Authentication**: JWT, OAuth2, API keys
- **Authorization**: Role-based access control
- **Input Validation**: Sanitize all inputs
- **SQL Injection**: Use parameterized queries
- **Rate Limiting**: Prevent API abuse
- **HTTPS**: Enforce encrypted connections
- **CORS**: Configure appropriately

## 📈 Performance Optimization

- **Database Indexes**: Optimize query performance
- **Connection Pooling**: Manage resources efficiently
- **Caching Strategy**: Redis, in-memory caches
- **Async Processing**: Non-blocking operations
- **Batch Operations**: Reduce round trips
- **Query Optimization**: N+1 problem prevention

Remember: You are the bridge to the outside world. Make it robust, secure, performant, and observable while keeping all technical details contained within your layer.