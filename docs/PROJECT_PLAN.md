# Project Plan
## Secure Access Gateway (SAG)

---

## 1. Project Phases

### Phase 0 — Planning & Design (Completed)
- Repository scaffolding
- Threat model documentation
- Architecture documentation
- OpenAPI specification
- Security-focused README

---

### Phase 1 — MVP Security Core

Objective: Implement core security enforcement capabilities.

Deliverables:
- JWT validation middleware
- Scope enforcement middleware
- Audit logging middleware
- Health endpoint
- Minimal backend stub

Milestone:
Phase 1 – MVP Security Core

---

### Phase 2 — Abuse & Network Controls

Objective: Protect gateway availability.

Deliverables:
- Rate limiting middleware
- IP allowlist / denylist enforcement
- Enhanced audit logging

---

### Phase 3 — Advanced Security

Objective: Harden against advanced attack vectors.

Deliverables:
- Request signing
- Replay detection
- Short-lived credential validation

---

### Phase 4 — Platform Polish

Objective: Improve production readiness.

Deliverables:
- Docker support
- GitHub Actions (linting, security checks)
- Metrics and observability hooks

---

## 2. Work Breakdown Structure (MVP)

1. Design middleware interfaces
2. Implement JWT validation middleware
3. Implement scope enforcement middleware
4. Implement audit logging
5. Add health endpoint
6. Update OpenAPI spec
7. Update README

---

## 3. Dependencies

- Swift + Vapor framework
- JWTKit
- SQLite (audit logs)
- GitHub Actions (later phases)

---

## 4. Risks

| Risk | Impact |
|----|-------|
| Underestimating complexity | Medium |
| Design changes mid-phase | Low |
| Overengineering MVP | Medium |

---

## 5. Tracking & Workflow

- All work tracked via GitHub Issues
- Issues grouped by milestone
- Pull requests required for `main`
- One feature per branch

---

## 6. Definition of Done (MVP)

- Code merged into `main`
- Tests pass where applicable
- Documentation updated
- MVP milestone closed
