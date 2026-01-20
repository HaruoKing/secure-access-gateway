import XCTVapor
import JWT
@testable import SecureAccessGateway

final class JWTValidationTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)

        // Set up test environment variables
        Environment.process.JWT_ISSUER = "https://test-issuer.com"
        Environment.process.JWT_AUDIENCE = "test-gateway"
        Environment.process.JWT_SIGNING_KEY = "test-secret-key"

        try await configure(app)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
        app = nil
    }

    // MARK: - Test Cases

    /// Test that health endpoint is accessible without JWT
    func testHealthEndpointIsUnauthenticated() async throws {
        try await app.test(.GET, "health") { res async in
            XCTAssertEqual(res.status, .ok)
        }
    }

    /// Test that protected endpoint rejects requests without Authorization header
    func testProtectedEndpointRejectsMissingToken() async throws {
        try await app.test(.GET, "protected") { res async in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }

    /// Test that protected endpoint rejects invalid authorization scheme
    func testProtectedEndpointRejectsInvalidScheme() async throws {
        try await app.test(.GET, "protected", headers: ["Authorization": "Basic abc123"]) { res async in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }

    /// Test that protected endpoint accepts valid JWT token
    func testProtectedEndpointAcceptsValidToken() async throws {
        // Create a valid JWT token
        let token = try createValidJWT()

        try await app.test(.GET, "protected", headers: ["Authorization": "Bearer \(token)"]) { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertTrue(res.body.string.contains("authenticated"))
        }
    }

    /// Test that expired tokens are rejected
    func testProtectedEndpointRejectsExpiredToken() async throws {
        // Create an expired JWT token
        let token = try createExpiredJWT()

        try await app.test(.GET, "protected", headers: ["Authorization": "Bearer \(token)"]) { res async in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }

    /// Test that tokens with invalid signature are rejected
    func testProtectedEndpointRejectsInvalidSignature() async throws {
        // Create a JWT with wrong signature
        let token = try createJWTWithInvalidSignature()

        try await app.test(.GET, "protected", headers: ["Authorization": "Bearer \(token)"]) { res async in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }

    /// Test that error responses don't leak sensitive information
    func testErrorResponsesDoNotLeakSensitiveInfo() async throws {
        try await app.test(.GET, "protected") { res async in
            XCTAssertEqual(res.status, .unauthorized)
            let body = res.body.string
            // Ensure no stack traces or internal error details
            XCTAssertFalse(body.contains("Error:"))
            XCTAssertFalse(body.contains("at "))
        }
    }

    // MARK: - Helper Methods

    /// Create a valid JWT token for testing
    private func createValidJWT() throws -> String {
        let signers = JWTKeyCollection()
        Task {
            await signers.add(hmac: "test-secret-key", digestAlgorithm: .sha256)
        }

        let payload = JWTPayload(
            sub: .init(value: "test-user-123"),
            exp: .init(value: Date().addingTimeInterval(3600)), // 1 hour from now
            iss: .init(value: "https://test-issuer.com"),
            aud: .init(value: "test-gateway")
        )

        return try signers.sign(payload)
    }

    /// Create an expired JWT token for testing
    private func createExpiredJWT() throws -> String {
        let signers = JWTKeyCollection()
        Task {
            await signers.add(hmac: "test-secret-key", digestAlgorithm: .sha256)
        }

        let payload = JWTPayload(
            sub: .init(value: "test-user-123"),
            exp: .init(value: Date().addingTimeInterval(-3600)), // 1 hour ago (expired)
            iss: .init(value: "https://test-issuer.com"),
            aud: .init(value: "test-gateway")
        )

        return try signers.sign(payload)
    }

    /// Create a JWT with invalid signature for testing
    private func createJWTWithInvalidSignature() throws -> String {
        let signers = JWTKeyCollection()
        Task {
            await signers.add(hmac: "wrong-secret-key", digestAlgorithm: .sha256)
        }

        let payload = JWTPayload(
            sub: .init(value: "test-user-123"),
            exp: .init(value: Date().addingTimeInterval(3600)),
            iss: .init(value: "https://test-issuer.com"),
            aud: .init(value: "test-gateway")
        )

        return try signers.sign(payload)
    }
}
