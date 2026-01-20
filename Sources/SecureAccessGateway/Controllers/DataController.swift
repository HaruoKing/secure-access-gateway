import Vapor

/// Controller for /api/data endpoints
struct DataController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api")

        // All /api/data routes require JWT validation
        let protected = api.grouped(JWTValidationMiddleware())
        let data = protected.grouped("data")

        // Apply scope-based authorization to each endpoint
        // GET /api/data requires "data:read" scope
        data.grouped(ScopeAuthorizationMiddleware(requiredScope: "data:read"))
            .get(use: read)

        // POST /api/data requires "data:write" scope
        data.grouped(ScopeAuthorizationMiddleware(requiredScope: "data:write"))
            .post(use: write)

        // DELETE /api/data requires "admin" scope
        data.grouped(ScopeAuthorizationMiddleware(requiredScope: "admin"))
            .delete(use: delete)
    }

    /// GET /api/data - Read protected data
    /// Requires: Valid JWT with read scope
    func read(req: Request) async throws -> Response {
        let payload = try req.auth.require(SAGJWTPayload.self)

        let response: [String: String] = [
            "message": "Read operation authorized",
            "subject": payload.sub.value,
            "data": "Protected data content"
        ]

        return try await response.encodeResponse(for: req)
    }

    /// POST /api/data - Write protected data
    /// Requires: Valid JWT with write scope
    func write(req: Request) async throws -> Response {
        let payload = try req.auth.require(SAGJWTPayload.self)

        let response: [String: String] = [
            "message": "Write operation authorized",
            "subject": payload.sub.value,
            "status": "Data written successfully"
        ]

        return try await response.encodeResponse(for: req)
    }

    /// DELETE /api/data - Delete protected data
    /// Requires: Valid JWT with admin scope
    func delete(req: Request) async throws -> Response {
        let payload = try req.auth.require(SAGJWTPayload.self)

        let response: [String: String] = [
            "message": "Delete operation authorized",
            "subject": payload.sub.value,
            "status": "Data deleted successfully"
        ]

        return try await response.encodeResponse(for: req)
    }
}
