import Vapor

/// Standard error response structure for all API errors
struct ErrorResponse: Content {
    /// Error type/code
    let error: String

    /// Human-readable error message
    let message: String

    /// Create a 401 Unauthorized error response
    static func unauthorized(_ message: String) -> ErrorResponse {
        ErrorResponse(error: "unauthorized", message: message)
    }

    /// Create a 403 Forbidden error response
    static func forbidden(_ message: String) -> ErrorResponse {
        ErrorResponse(error: "forbidden", message: message)
    }
}
