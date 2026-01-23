# Seamless Call — API Contract (Flutter Consumption View) (v1)

This file describes the backend API **as consumed by the Flutter app**.
Backend repo remains the source of truth; this document must match it.

## Environments
- Local (Laragon): TBD
- LAN (device testing): TBD
- Production: TBD

## Authentication
- Token type: Bearer (assumed from existing discussions)
- Token storage: Flutter Secure Storage (observed dependency in past code)

### Auth endpoints
| Purpose | Method | Path | Auth? | Request | Success Response | Error Response |
|---|---:|---|---:|---|---|---|
| Login | POST | `/api/v1/login` | No | `{ email_or_phone, password }` | `{ data: { token, user } }` (TBD) | `{ message, errors? }` (TBD) |
| Logout | POST | `/api/v1/logout` | Yes | none | TBD | TBD |

## Admin
(Add endpoints as implemented)

## Provider
(Add endpoints as implemented)

## Customer
(Add endpoints as implemented)

## Conventions
- Response envelope: TBD (often `{ status, message, data }` or `{ data: ... }`)
- Error envelope: TBD
- Pagination: TBD

## Notes / Known pitfalls
- Base URL must align with CI4 vhost (`/public` vs non-`/public`) and route prefix (`/api/v1`).
