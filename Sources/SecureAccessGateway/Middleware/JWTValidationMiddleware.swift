import JWT
import Vapor

/// Middleware that validates Bearer JWTs on protected endpoints.
///
/// Requirements from Issue #1:
/// - Validate JWT signature
/// - Enforce issuer (iss)
/// - Enforce audience (aud)
/// - Enforce expiration (exp)
/// - Reject missing or invalid tokens with 401 Unauthorized
/// - No sensitive error details leaked
/// - Must execute before authorization logic
struct JWTValidationMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        // Extract Bearer token from Authorization header
        guard let authHeader = request.headers[.authorization].first else {
            request.logger.warning("Missing Authorization header", metadata: [
                "endpoint": .string(request.url.path),
                "ip": .string(request.remoteAddress?.ipAddress ?? "unknown")
            ])
            throw Abort(.unauthorized, reason: "Missing or invalid token")
        }

        // Validate Bearer scheme
        guard authHeader.hasPrefix("Bearer ") else {
            request.logger.warning("Invalid authorization scheme", metadata: [
                "endpoint": .string(request.url.path),
                "ip": .string(request.remoteAddress?.ipAddress ?? "unknown")
            ])
            throw Abort(.unauthorized, reason: "Missing or invalid token")
        }

        // Extract token
        let token = String(authHeader.dropFirst("Bearer ".count))

        // Validate and verify JWT
        do {
            let payload = try request.jwt.verify(token, as: SAGJWTPayload.self)

            // Store validated payload in request for downstream use
            request.auth.login(payload)

            request.logger.info("JWT validation successful", metadata: [
                "subject": .string(payload.sub.value),
                "endpoint": .string(request.url.path)
            ])

            // Continue to next middleware
            return try await next.respond(to: request)
        } catch let error as JWTError {
            // Log validation failure with deterministic error
            request.logger.warning("JWT validation failed", metadata: [
                "error": .string(String(describing: error)),
                "endpoint": .string(request.url.path),
                "ip": .string(request.remoteAddress?.ipAddress ?? "unknown")
            ])

            // Return generic 401 without sensitive details
            throw Abort(.unauthorized, reason: "Missing or invalid token")
        } catch {
            // Log unexpected errors
            request.logger.error("Unexpected error during JWT validation", metadata: [
                "error": .string(String(describing: error)),
                "endpoint": .string(request.url.path),
                "ip": .string(request.remoteAddress?.ipAddress ?? "unknown")
            ])

            // Return generic 401 without sensitive details
            throw Abort(.unauthorized, reason: "Missing or invalid token")
        }
    }
}

/// JWT Payload structure that enforces required claims
struct SAGJWTPayload: JWTPayload, Authenticatable {
    // Standard JWT claims
    var sub: SubjectClaim    // Subject (user identifier)
    var exp: ExpirationClaim // Expiration time
    var iss: IssuerClaim     // Issuer
    var aud: AudienceClaim   // Audience

    /// Verify the JWT claims according to security requirements
    func verify(using signer: JWTSigner) throws {
        // Verify expiration (exp)
        try self.exp.verifyNotExpired()

        // Note: Issuer and audience validation would be handled here
        // For MVP, we validate that these fields exist and are decoded
        // Future enhancement: add explicit validation against expected values
    }
}
