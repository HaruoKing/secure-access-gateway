import Vapor

/// Middleware that enforces scope-based authorization on protected endpoints.
///
/// Requirements from Issue #2:
/// - Map routes to required scopes
/// - Enforce deny-by-default behavior
/// - Reject requests missing required scopes with 403 Forbidden
/// - Authorization logic centralized and independent of JWT validation
/// - Authorization decisions are auditable
struct ScopeAuthorizationMiddleware: AsyncMiddleware {
    let requiredScope: String

    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        // Retrieve the authenticated JWT payload
        guard let payload = request.auth.get(SAGJWTPayload.self) else {
            // JWT validation should have run before this middleware
            request.logger.error("ScopeAuthorizationMiddleware executed without JWT validation", metadata: [
                "endpoint": .string(request.url.path),
                "ip": .string(request.remoteAddress?.ipAddress ?? "unknown")
            ])

            let errorResponse = ErrorResponse.unauthorized("Authentication required")
            return try await errorResponse.encodeResponse(status: .unauthorized, for: request)
        }

        // Check if the user has the required scope
        guard payload.hasScope(requiredScope) else {
            // Log authorization denial for audit
            request.logger.warning("Authorization denied: insufficient scope", metadata: [
                "subject": .string(payload.sub.value),
                "endpoint": .string(request.url.path),
                "method": .string(request.method.rawValue),
                "required_scope": .string(requiredScope),
                "user_scopes": .string(payload.scope),
                "ip": .string(request.remoteAddress?.ipAddress ?? "unknown"),
                "decision": .string("DENY")
            ])

            let errorResponse = ErrorResponse.forbidden(
                "Missing required scope: \(requiredScope)"
            )
            return try await errorResponse.encodeResponse(status: .forbidden, for: request)
        }

        // Log authorization success for audit
        request.logger.info("Authorization granted", metadata: [
            "subject": .string(payload.sub.value),
            "endpoint": .string(request.url.path),
            "method": .string(request.method.rawValue),
            "required_scope": .string(requiredScope),
            "decision": .string("ALLOW")
        ])

        // Continue to the next middleware/handler
        return try await next.respond(to: request)
    }
}
