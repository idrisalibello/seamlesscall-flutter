# Seamless Call — API Contract (Flutter Consumption View) (v1.5)

Backend repository is the source of truth.  
This file mirrors **all confirmed backend routes** in a Flutter-friendly, lossless format.

---

## Base URL (Flutter)
Defined in:
- `lib/core/network/dio_client.dart`

Current value:
- `http://10.186.11.59/seamless_call/`

All endpoint paths below are appended to this base URL.

---

## Authentication
- Scheme: `Authorization: Bearer <token>`
- Token storage: `FlutterSecureStorage`
- Storage key: `auth_token`
- Token injection: automatically attached by `DioClient`
- Auth failure behavior:
  - Backend returns HTTP 401
  - `DioClient` converts this to marker error: `AUTH_EXPIRED`
  - UI/Auth layer handles logout and navigation

---

## API PREFIXES (IMPORTANT)
All APIs are module-scoped:

- Auth: `/api/v1`
- Dashboard: `/api/v1/dashboard`
- Admin: `/api/v1/admin`
- Operations: `/api/v1/operations`
- System: `/api/v1/system`

Never omit `/api/v1`.

---

## AUTH MODULE (`/api/v1`)
No authentication required unless stated.

- `POST /api/v1/register`
  - Register a new user

- `POST /api/v1/login`
  - Login using email/phone + password

- `POST /api/v1/auth/otp/request`
  - Request OTP for login

- `POST /api/v1/auth/otp/login`
  - Login using OTP

- `POST /api/v1/auth/apply-as-provider`
  - Apply to become a provider
  - Requires authentication

---

## DASHBOARD MODULE (`/api/v1/dashboard`)
All routes require authentication.

- `GET /api/v1/dashboard/stats`
  - Returns dashboard statistics for authenticated user
  - Used by admin/dashboard screens

---

## ADMIN MODULE (`/api/v1/admin`)
All routes require authentication.

### Provider onboarding
- `GET /api/v1/admin/provider-applications`
  - List pending provider applications

- `POST /api/v1/admin/provider-applications/status`
  - Approve or reject provider application

### Admin users
- `POST /api/v1/admin/users`
  - Create an admin user

### Customers & providers
- `GET /api/v1/admin/customers`
  - List customers

- `GET /api/v1/admin/providers`
  - List providers

### User details
- `GET /api/v1/admin/users/{id}`
  - Get user profile

- `GET /api/v1/admin/users/{id}/ledger`
  - Get user ledger

- `GET /api/v1/admin/users/{id}/refunds`
  - Get user refunds

- `GET /api/v1/admin/users/{id}/activity`
  - Get user activity log

### Provider finance
- `GET /api/v1/admin/providers/{id}/earnings`
  - Get provider earnings

- `GET /api/v1/admin/providers/{id}/payouts`
  - Get provider payouts

### Categories
- `GET /api/v1/admin/categories`
- `GET /api/v1/admin/categories/{id}`
- `POST /api/v1/admin/categories`
- `PUT /api/v1/admin/categories/{id}`
- `PATCH /api/v1/admin/categories/{id}`
- `DELETE /api/v1/admin/categories/{id}`

### Services
- `GET /api/v1/admin/categories/{categoryId}/services`
  - List services in category

- `POST /api/v1/admin/categories/{categoryId}/services`
  - Create service in category

- `PUT /api/v1/admin/services/{serviceId}`
  - Update service

- `DELETE /api/v1/admin/services/{serviceId}`
  - Delete service

### Roles & permissions (user management)
- `GET /api/v1/admin/users`
  - List all users

- `PUT /api/v1/admin/users/{id}`
  - Update user details

- `GET /api/v1/admin/users/{id}/roles`
  - Get user roles

- `PUT /api/v1/admin/users/{id}/roles`
  - Update user roles

---

## OPERATIONS MODULE (`/api/v1/operations`)
All routes require authentication.

### Provider operations
- `GET /api/v1/operations/provider/jobs`
  - Get active jobs for provider

- `GET /api/v1/operations/provider/jobs/{jobId}`
  - Get job details

- `PUT /api/v1/operations/provider/jobs/{jobId}/status`
  - Update job status

### Admin operations
- `GET /api/v1/operations/admin/jobs`
  - Get all active jobs

- `GET /api/v1/operations/admin/jobs/pending`
  - Get pending jobs

- `GET /api/v1/operations/admin/jobs/{jobId}`
  - Get job details

- `POST /api/v1/operations/admin/jobs/{jobId}/assign`
  - Assign provider to job

- `GET /api/v1/operations/admin/providers/available`
  - Get available providers

---

## SYSTEM MODULE (`/api/v1/system`)
All routes require authentication.

### Roles
- `GET /api/v1/system/roles`
  - List roles

- `POST /api/v1/system/roles`
  - Create role

### Permissions
- `GET /api/v1/system/permissions`
  - List permissions

- `GET /api/v1/system/roles/{roleId}/permissions`
  - Get permissions assigned to role

- `PUT /api/v1/system/roles/{roleId}/permissions`
  - Update role permissions

---

## Known pitfalls (do not ignore)
- Base URL **must not** include `/api/v1`
- `/api/v1` is part of the path, not the base
- Flutter Web requires:
  - CORS enabled
  - OPTIONS preflight allowed
  - `Authorization` header allowed
- Do not assume routes — always refer to this file
