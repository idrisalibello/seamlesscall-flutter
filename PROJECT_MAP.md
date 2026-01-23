# Seamless Call — Flutter Project Map (v1)

## Repo root (what matters)
- `assets/` — static assets (e.g., `assets/images/`)
- `lib/` — application source
- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` — platform targets

Ignored (generated/tooling):
- `.dart_tool/`, `build/`, plugin symlinks, device/browser profiles

## Architecture (observed)
- **Core layer**: `lib/core/` (shared infrastructure)
- **Common layer**: `lib/common/` (constants, utils, shared widgets)
- **App shell**: `lib/app_shell/` (top-level navigation/layout)
- **Feature-first modules**: `lib/features/<feature>/...`

## Networking (authoritative)
**Single source of truth**
- `lib/core/network/dio_client.dart` — owns the single `Dio` instance

**Auth header policy**
- Reads token from `FlutterSecureStorage` key: `auth_token`
- Injects `Authorization: Bearer <token>` when present
- Supports test override via `setTokenForTest(token)`

**Hard constraint (prevents drift)**
- `DioClient` MUST NOT import or depend on:
  - `BuildContext`, Widgets, navigation
  - Provider/Riverpod state
  - feature presentation code
- `DioClient` may only:
  - attach headers
  - normalize/propagate errors

**401 handling (current)**
- HTTP 401 is normalized to a typed marker error: `AUTH_EXPIRED`
- Logout/navigation is handled outside core (UI/auth layer)

## Common (shared)
- `lib/common/constants/` — app constants (themes, base URLs if moved there)
- `lib/common/utils/` — helpers
- `lib/common/widgets/` — reusable UI widgets

## App shell
- `lib/app_shell/presentation/` — shell UI (navigation scaffold, routing entry points)

## Features (observed in tree)
- `lib/features/admin/`
  - `data/`, `presentation/`
- `lib/features/auth/`
  - `data/`, `domain/`, `presentation/`
- `lib/features/config/`
  - `data/models/`
- `lib/features/customer/`
  - `presentation/`
- `lib/features/dashboard/`
  - `data/`
- `lib/features/finance/` — (not expanded)
- `lib/features/operations/`
  - `application/`, `data/repositories/`, `domain/`
- `lib/features/people/`
  - `data/models/`
- `lib/features/providers/`
  - `data/`, `presentation/`
- `lib/features/reports/` — (not expanded)
- `lib/features/system/`
  - `application/`, `data/models/`, `data/repositories/`, `presentation/`

## Golden files (first to reference during bugs)
1. `lib/core/network/dio_client.dart`
2. `lib/features/auth/data/*` and `lib/features/auth/presentation/*`
3. `lib/main.dart`
4. `lib/app_shell/presentation/*`
5. Any base URL config in `lib/common/constants/*`

## Bug report format (required)
- Error log
- File path(s)
- 30–80 relevant lines only
- Call chain: Screen → Provider → Repo → DioClient → Endpoint
