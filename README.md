## Security Controls

The Secure Access Gateway (SAG) enforces multiple layered security controls based on **Zero Trust** and **defense-in-depth** principles.  
All requests are treated as untrusted until explicitly validated and authorized.

### Authentication Validation
- Requires a valid **Bearer JWT** on protected endpoints
- Verifies token signature, issuer, audience, and expiration
- Tokens are **validated only** (not issued) by the gateway

**Threats mitigated:**
- Unauthorized access
- Token forgery
- Expired or tampered tokens

---

### Authorization (Scope Enforcement)
- Each endpoint is mapped to one or more required scopes
- Requests lacking required scopes are denied by default
- Authorization decisions are enforced centrally at the gateway

**Threats mitigated:**
- Privilege escalation
- Over-broad access
- Improper authorization logic in backend services

---

### Rate Limiting
- Enforced per IP address and per token subject
- Uses a sliding time window model
- Violations result in immediate request denial

**Threats mitigated:**
- Brute force attacks
- API scraping
- Denial-of-service amplification

---

### IP Filtering
- Supports explicit allowlists and denylists
- Deny rules take precedence over allow rules
- Executed early in the request lifecycle

**Threats mitigated:**
- Known malicious sources
- Unauthorized network access

---

### Request Integrity & Replay Protection
- Optional HMAC-based request signatures
- Timestamp validation to prevent replay attacks
- Requests outside the allowed time window are rejected

**Threats mitigated:**
- Replay attacks
- Message tampering
- Man-in-the-middle reuse of captured requests

---

### Audit Logging
- Every request is logged with:
  - Timestamp
  - Source IP
  - Target endpoint
  - Authorization decision (ALLOW / DENY)
  - Reason for decision
- Logs are append-only and designed for forensic analysis

**Threats mitigated:**
- Undetected abuse
- Insider misuse
- Lack of accountability

---

### Secure Failure Handling
- All failures are explicit and deterministic
- No sensitive information is leaked in error responses
- Common failure responses:
  - `401 Unauthorized`
  - `403 Forbidden`
  - `429 Too Many Requests`

**Threats mitigated:**
- Information disclosure
- Undefined or unsafe error behavior

---

### Security Philosophy

The Secure Access Gateway acts as a **policy enforcement point**, not an identity provider.  
All security decisions are centralized, explicit, logged, and enforce least privilege by default.
