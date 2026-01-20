import Vapor

/// Controller for health check endpoints
struct HealthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("health", use: check)
    }

    /// GET /health - Health check endpoint (unauthenticated)
    /// Returns 200 OK if the gateway is operational
    func check(req: Request) async throws -> HTTPStatus {
        return .ok
    }
}
