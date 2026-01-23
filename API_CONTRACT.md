# Seamless Call — API Contract (Flutter Consumption View) (v1)

This file describes the backend API **as consumed by the Flutter app**.
Backend repo remains the source of truth; this document must match it.

## Environment / Base URL (current)
- Base URL is currently hard-coded in `lib/core/network/dio_client.dart`:
  - `http://10.186.11.59/seamless_call/`
- Route prefix (`/api/v1`) must be included in endpoint paths where applicable.

## Authentication
- Scheme: `Authorization: Bearer <token>`
- Storage: `FlutterSecureStorage`, key `auth_token`
- Injection: `DioClient` request interceptor attaches Bearer token automatically when available.

### Auth failure handling
- Backend returns HTTP 401 for expired/invalid tokens.
- Flutter normalizes 401 to error marker: `AUTH_EXPIRED`.
- UI/auth layer decides how to logout and navigate.

## Endpoints (populate as you implement)
| Domain | Purpose | Method | Path | Auth? | Request | Success Response | Error Response |
|---|---|---:|---|---:|---|---|---|
| Auth | Login | POST | `/api/v1/login` | No | `{ email_or_phone, password }` | TBD | TBD |
| Auth | Logout | POST | `/api/v1/logout` | Yes | none | TBD | TBD |

## Response conventions (TBD)
- Envelope shape: TBD (e.g., `{ data, message }` or `{ status, data }`)
- Error shape: TBD
- Pagination: TBD

## Notes / Known pitfalls
- Avoid mixing `/public` and non-`/public` base URLs across environments.
- Keep `/api/v1` consistent across all endpoints.
