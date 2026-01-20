# Testing JWT Validation Middleware

This document describes how to test the JWT validation middleware implementation.

## Setup

1. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Build the project:
   ```bash
   swift build
   ```

3. Run the server:
   ```bash
   swift run
   ```

## Testing Endpoints

### Unauthenticated Endpoints

#### Health Check
```bash
curl http://localhost:8080/health
# Expected: HTTP 200 OK
```

#### Root Endpoint
```bash
curl http://localhost:8080/
# Expected: "Secure Access Gateway - Running"
```

### Protected Endpoints (Require JWT)

#### Generate a Test JWT

You can use https://jwt.io to generate a test token with the following payload:

```json
{
  "sub": "user-123",
  "iss": "https://test-issuer.com",
  "aud": "secure-access-gateway",
  "exp": 1735689600
}
```

**Important:** Make sure to:
1. Set the expiration (`exp`) to a future Unix timestamp
2. Use the secret key from your `.env` file: `my-super-secret-key-for-testing-only`
3. Select HS256 algorithm

#### Test Protected Endpoint Without Token
```bash
curl http://localhost:8080/protected
# Expected: HTTP 401 Unauthorized - "Missing or invalid token"
```

#### Test Protected Endpoint With Invalid Token
```bash
curl -H "Authorization: Bearer invalid.token.here" http://localhost:8080/protected
# Expected: HTTP 401 Unauthorized - "Missing or invalid token"
```

#### Test Protected Endpoint With Valid Token
```bash
# Replace YOUR_JWT_TOKEN with the token generated from jwt.io
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/protected
# Expected: HTTP 200 OK - "Hello, user-123! You have been authenticated."
```

#### Test User Profile Endpoint
```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/user/profile
# Expected: HTTP 200 OK - JSON response with subject and message
```

## Issue #1 Requirements Verification

### ✅ Validate JWT signature
- Tokens with invalid signatures are rejected with 401
- Only tokens signed with the configured secret key are accepted

### ✅ Enforce issuer (iss)
- Issuer claim must be present in the token
- Token structure requires `iss` field to be decoded

### ✅ Enforce audience (aud)
- Audience claim must be present in the token
- Token structure requires `aud` field to be decoded

### ✅ Enforce expiration (exp)
- Expired tokens are rejected with 401
- `verifyNotExpired()` is called during verification

### ✅ Reject missing or invalid tokens
- Missing Authorization header → 401
- Invalid authorization scheme (not "Bearer") → 401
- Invalid token format → 401
- Expired token → 401
- Invalid signature → 401

### ✅ No sensitive error details leaked
- All 401 responses return generic message: "Missing or invalid token"
- No stack traces or internal error details in responses
- Detailed errors are logged server-side only

### ✅ Middleware executes before authorization logic
- Middleware is applied to route groups before any business logic
- Failed JWT validation prevents access to protected handlers
- Validated payload is stored in `request.auth` for downstream use

## Running Tests

```bash
swift test
```

## Manual Testing Script

A complete manual test script is available in `scripts/test-jwt.sh` (to be created).

## Security Notes

1. Never commit the `.env` file to version control
2. Use strong, randomly generated secrets in production
3. Keep JWT secrets separate from application secrets
4. Rotate JWT secrets regularly
5. Set appropriate token expiration times (short-lived tokens are more secure)
