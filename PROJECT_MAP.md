# Seamless Call — Flutter Project Map (v1)

## Repo root
- `assets/` — static assets (currently `assets/images/`)
- `lib/` — application source
- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` — platform targets
- `.dart_tool/`, `build/` — generated (do not edit)

## Architecture (observed)
This repo is organized as:
- **Core layer**: `lib/core/` (shared infrastructure)
- **Common layer**: `lib/common/` (constants, utils, shared widgets)
- **App shell**: `lib/app_shell/` (top-level navigation / layout entry points)
- **Feature-first modules**: `lib/features/<feature>/...`

## Key folders

### `lib/core/`
- `lib/core/network/dio_client.dart`
  - Single source of truth for all HTTP requests
  - Owns Dio instance, interceptors, headers, and auth token injection
  - All repositories MUST use this client (no direct Dio creation elsewhere)


### `lib/common/`
- `lib/common/constants/` — themes, base URLs, fixed values
- `lib/common/utils/` — helpers
- `lib/common/widgets/` — reusable UI widgets

### `lib/app_shell/`
- `lib/app_shell/presentation/` — shell UI (navigation scaffold, routing entry points)

## Features (observed in tree)

### `lib/features/admin/`
- `data/` — DTOs/models/repositories (backend-facing)
- `presentation/` — UI screens/widgets

### `lib/features/auth/`
- `data/` — API calls, token persistence glue, repositories
- `domain/` — entities/use-cases (business logic)
- `presentation/` — login/splash/auth screens + providers

### `lib/features/config/`
- `data/models/` — configuration models (remote/local config)

### `lib/features/customer/`
- `presentation/` — customer-facing UI

### `lib/features/dashboard/`
- `data/` — dashboard data aggregation layer (stats/summary inputs)

### `lib/features/finance/`
- (structure not expanded in tree output)

### `lib/features/operations/`
- `application/` — application services / coordinators (use-case implementations)
- `data/repositories/` — repositories for operations
- `domain/` — domain entities and abstractions

### `lib/features/people/`
- `data/models/` — people/provider/customer models (as named in your app)

### `lib/features/providers/`
- `data/` — provider data layer
- `presentation/` — provider UI

### `lib/features/reports/`
- (structure not expanded in tree output)

### `lib/features/system/`
- `application/` — system-level services
- `data/models/` — system models
- `data/repositories/` — repositories
- `presentation/` — system/admin system UI screens

## “Golden files” (must be kept accurate)
When debugging, these file paths are the first things we reference (you will paste small snippets, not whole files):
1. **Networking**
   - `lib/core/network/*` (DioClient, interceptors, base URL selection)
   - Any base URL constant in `lib/common/constants/*`
2. **Auth**
   - `lib/features/auth/data/*` (token storage, login calls)
   - `lib/features/auth/presentation/*` (AuthProvider / state)
3. **App entry / navigation**
   - `lib/main.dart`
   - `lib/app_shell/presentation/*`

## Working agreement (to prevent drift)
- We do not assume file locations. We use this map + exact paths.
- Bug reports must include: error log + file path + 30–80 relevant lines + call chain.

## TODO (next inputs needed to make this map precise)
Paste the contents (or relevant sections) of:
- `lib/core/network/` (file list at minimum)
- `lib/main.dart`
- the file that defines the base URL (often in `lib/common/constants/`)
