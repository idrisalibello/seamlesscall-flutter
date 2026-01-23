# Seamless Call — API Contract (Flutter Consumption View) (v1.1)

This file describes the backend API **as consumed by the Flutter app**.
Backend repo remains the source of truth; this document must match it.

---

## Base URL (current in Flutter)
Defined in `lib/core/network/dio_client.dart`:
- `http://10.186.11.59/seamless_call/`

All endpoint paths below are appended to that base URL.

---

## Authentication
- Scheme: `Authorization: Bearer <token>`
- Storage: `FlutterSecureStorage`, key `auth_token`
- Injection: `DioClient` request interceptor attaches Bearer token automatically when available.

### Auth failure handling (Flutter)
- Backend returns HTTP 401 for expired/invalid tokens.
- `DioClient` normalizes 401 to marker error: `AUTH_EXPIRED`.
- UI/auth layer decides logout + navigation.

---

## Confirmed endpoints

### Auth (`/api/v1`)
| Purpose | Method | Path | Auth? |
|---|---:|---|---:|
| Register | POST | `/api/v1/register` | No |
| Login (password) | POST | `/api/v1/login` | No |
| Request login OTP | POST | `/api/v1/auth/otp/request` | No |
| Login with OTP | POST | `/api/v1/auth/otp/login` | No |
| Apply as Provider | POST | `/api/v1/auth/apply-as-provider` | Yes |

### Admin (`/api/v1/admin`) — all require auth
| Purpose | Method | Path |
|---|---:|---|
| List provider applications | GET | `/api/v1/admin/provider-applications` |
| Approve/reject provider application | POST | `/api/v1/admin/provider-applications/status` |
| Create admin user | POST | `/api/v1/admin/users` |
| Get customers | GET | `/api/v1/admin/customers` |
| Get providers | GET | `/api/v1/admin/providers` |
| Get user details | GET | `/api/v1/admin/users/{id}` |
| Get user ledger | GET | `/api/v1/admin/users/{id}/ledger` |
| Get user refunds | GET | `/api/v1/admin/users/{id}/refunds` |
| Get user activity log | GET | `/api/v1/admin/users/{id}/activity` |
| Get provider earnings | GET | `/api/v1/admin/providers/{id}/earnings` |
| Get provider payouts | GET | `/api/v1/admin/providers/{id}/payouts` |

#### Admin — Categories & Services
| Purpose | Method | Path |
|---|---:|---|
| List services by category | GET | `/api/v1/admin/categories/{categoryId}/services` |
| Create service in category | POST | `/api/v1/admin/categories/{categoryId}/services` |
| Update service | PUT | `/api/v1/admin/services/{serviceId}` |
| Delete service | DELETE | `/api/v1/admin/services/{serviceId}` |

#### Admin — Categories resource routes (expected)
Resource: `categories` under `/api/v1/admin`
- `GET /api/v1/admin/categories`
- `GET /api/v1/admin/categories/{id}`
- `POST /api/v1/admin/categories`
- `PUT|PATCH /api/v1/admin/categories/{id}`
- `DELETE /api/v1/admin/categories/{id}`

#### Admin — User management (roles & permissions)
| Purpose | Method | Path |
|---|---:|---|
| List users | GET | `/api/v1/admin/users` |
| Update user | PUT | `/api/v1/admin/users/{id}` |
| Get user roles | GET | `/api/v1/admin/users/{id}/roles` |
| Update user roles | PUT | `/api/v1/admin/users/{id}/roles` |

---

## Notes / Known pitfalls
- Keep hosting mode consistent (`/public` vs repo-root DocumentRoot) to avoid 404s.
- Flutter Web requires correct CORS + OPTIONS preflight support.
- Always include `/api/v1` in paths (module-defined).
