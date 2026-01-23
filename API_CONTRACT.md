# Seamless Call — API Contract (Flutter Consumption View) (v1.3)

Backend repo is the source of truth. This file mirrors confirmed routes.

---

## Base URL (Flutter)
Defined in `lib/core/network/dio_client.dart`:
- `http://10.186.11.59/seamless_call/`

All endpoint paths below are appended to that base URL.

---

## Authentication
- Scheme: `Authorization: Bearer <token>`
- Storage: `FlutterSecureStorage`, key `auth_token`
- Injection: `DioClient` request interceptor attaches Bearer token automatically when available.
- On HTTP 401: `DioClient` normalizes to marker error `AUTH_EXPIRED`.

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

### Operations (`/api/v1/operations`) — all require auth
#### Provider routes
| Purpose | Method | Path |
|---|---:|---|
| Get provider job details | GET | `/api/v1/operations/provider/jobs/{jobId}` |
| Update provider job status | PUT | `/api/v1/operations/provider/jobs/{jobId}/status` |
| Get provider active jobs | GET | `/api/v1/operations/provider/jobs` |

#### Admin routes
| Purpose | Method | Path |
|---|---:|---|
| Get pending jobs | GET | `/api/v1/operations/admin/jobs/pending` |
| Get job details | GET | `/api/v1/operations/admin/jobs/{jobId}` |
| Assign provider to job | POST | `/api/v1/operations/admin/jobs/{jobId}/assign` |
| Get available providers | GET | `/api/v1/operations/admin/providers/available` |

### System (`/api/v1/system`) — all require auth
#### Roles
| Purpose | Method | Path |
|---|---:|---|
| Get roles | GET | `/api/v1/system/roles` |
| Create role | POST | `/api/v1/system/roles` |

#### Permissions
| Purpose | Method | Path |
|---|---:|---|
| Get permissions | GET | `/api/v1/system/permissions` |
| Get role permissions | GET | `/api/v1/system/roles/{roleId}/permissions` |
| Update role permissions | PUT | `/api/v1/system/roles/{roleId}/permissions` |

---

## Notes / Known pitfalls
- Keep hosting mode consistent (`/public` vs repo-root DocumentRoot) to avoid 404s.
- Flutter Web requires correct CORS + OPTIONS preflight support.
