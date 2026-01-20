import JWT
import Vapor

/// Configuration for JWT validation
struct JWTConfiguration {
    /// Expected issuer (iss) claim
    let issuer: String

    /// Expected audience (aud) claim
    let audience: String

    /// JWT signing key (can be secret or public key)
    let signingKey: String

    /// Initialize from environment variables
    static func fromEnvironment(_ environment: Environment) throws -> JWTConfiguration {
        guard let issuer = Environment.get("JWT_ISSUER") else {
            throw ConfigurationError.missingEnvironmentVariable("JWT_ISSUER")
        }

        guard let audience = Environment.get("JWT_AUDIENCE") else {
            throw ConfigurationError.missingEnvironmentVariable("JWT_AUDIENCE")
        }

        guard let signingKey = Environment.get("JWT_SIGNING_KEY") else {
            throw ConfigurationError.missingEnvironmentVariable("JWT_SIGNING_KEY")
        }

        return JWTConfiguration(
            issuer: issuer,
            audience: audience,
            signingKey: signingKey
        )
    }
}

/// Configuration errors
enum ConfigurationError: Error, CustomStringConvertible {
    case missingEnvironmentVariable(String)

    var description: String {
        switch self {
        case .missingEnvironmentVariable(let name):
            return "Missing required environment variable: \(name)"
        }
    }
}

/// Extension to configure JWT signers with validation
extension Application {
    /// Configure JWT validation with issuer and audience enforcement
    func configureJWT(with config: JWTConfiguration) {
        // Add HMAC-SHA256 signer with the provided key
        self.jwt.signers.use(.hs256(key: config.signingKey))

        // Store configuration for later use
        self.storage[JWTConfigurationKey.self] = config
    }

    /// Access JWT configuration
    var jwtConfig: JWTConfiguration? {
        get { self.storage[JWTConfigurationKey.self] }
        set { self.storage[JWTConfigurationKey.self] = newValue }
    }
}

/// Storage key for JWT configuration
private struct JWTConfigurationKey: StorageKey {
    typealias Value = JWTConfiguration
}
