import JWT
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // Load JWT configuration from environment
    let jwtConfig = try JWTConfiguration.fromEnvironment(app.environment)

    // Configure JWT validation with issuer and audience enforcement
    app.configureJWT(with: jwtConfig)

    // Register middleware (order matters - JWT validation before authorization)
    // Note: JWT middleware will be selectively applied to protected routes
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))

    // register routes
    try routes(app)
}
