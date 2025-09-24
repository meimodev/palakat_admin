## 2025-09-23T22:51:35+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: Fixed compile errors by aligning ColumnEditDrawer and ChurchScreen with the `Column` model (name instead of number, int id, timestamps, churchId). No new persistent memories.

## 2025-09-23T15:39:28+08:00 — Model: Cascade
## 2025-09-23T16:27:51+08:00 — Model: Cascade
- [memory_change]
  - action: create
  - id: 21f10463-cf1f-4827-818b-17290f9488c3
  - title: Add ChurchController with mock data and loading; refactor ChurchScreen to use provider
  - tags: [church, riverpod_generator, state_management, ui_refactor]
  - content: Introduced ChurchController using Riverpod Generator to manage Church profile state. Moved all mock Church data into the controller and added simulated loading (1s delay). Updated ChurchScreen to consume provider, show loading/error via AsyncValue, centralize mock member lookup, and update state via controller.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.
- id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - user_triggered: false
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.
- id: 8e013dbd-7cff-4910-b964-045871a641d4
  - title: Shared ErrorMapper for centralized Dio/AppError mapping and unknown error wrapping
  - tags: [error_handling, architecture, dio, app_error, utility]
  - user_triggered: false
  - content: Created a shared ErrorMapper utility at lib/core/utils/error_mapper.dart to centralize mapping of DioException to AppError and wrapping unknown exceptions. Refactored ApiService and AuthRepository to use ErrorMapper, removing duplicated error mapping code. Standard guideline: repository and service layers should catch DioException and map via ErrorMapper, and catch all other exceptions and wrap as AppError.unknown.
- id: 21f10463-cf1f-4827-818b-17290f9488c3
  - title: Add ChurchController with mock data and loading; refactor ChurchScreen to use provider
  - tags: [church, riverpod_generator, state_management, ui_refactor]
  - user_triggered: false
  - content: Introduced ChurchController using Riverpod Generator to manage Church profile state. Moved all mock Church data into the controller and added simulated loading (1s delay). Updated ChurchScreen to consume provider, show loading/error via AsyncValue, centralize mock member lookup, and update state via controller.
- [memory_change]
  - action: none
  - note: Fixed compile errors by adjusting imports/types and providing Location instance in mock; no persistent memory updates required.

## 2025-09-23T15:32:03+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: Added `Location` model and updated `Church` with nullable `location`; no persistent preference or architecture memory updates required.

## 2025-09-23T15:16:03+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: Refactored Church model and updated related UI; no persistent memory changes required for preferences or architecture.

## 2025-09-23T13:20:51+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

## 2025-09-23T13:50:27+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

## 2025-09-23T14:09:40+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

## 2025-09-23T10:58:05+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

## 2025-09-23T13:12:00+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.
- id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - user_triggered: false
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.
- id: 8e013dbd-7cff-4910-b964-045871a641d4
  - title: Shared ErrorMapper for centralized Dio/AppError mapping and unknown error wrapping
  - tags: [error_handling, architecture, dio, app_error, utility]
  - user_triggered: false
  - content: Created a shared ErrorMapper utility at lib/core/utils/error_mapper.dart to centralize mapping of DioException to AppError and wrapping unknown exceptions. Refactored ApiService and AuthRepository to use ErrorMapper, removing duplicated error mapping code. Standard guideline: repository and service layers should catch DioException and map via ErrorMapper, and catch all other exceptions and wrap as AppError.unknown.

## 2025-09-23T10:58:05+08:00 — Model: Cascade
 - [memory_change]
   - action: none
   - note: No new memories added/updated/deleted for this step.
 
### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.
- id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - user_triggered: false
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.
- id: 8e013dbd-7cff-4910-b964-045871a641d4
  - title: Shared ErrorMapper for centralized Dio/AppError mapping and unknown error wrapping
  - tags: [error_handling, architecture, dio, app_error, utility]
  - user_triggered: false
  - content: Created a shared ErrorMapper utility at lib/core/utils/error_mapper.dart to centralize mapping of DioException to AppError and wrapping unknown exceptions. Refactored ApiService and AuthRepository to use ErrorMapper, removing duplicated error mapping code. Standard guideline: repository and service layers should catch DioException and map via ErrorMapper, and catch all other exceptions and wrap as AppError.unknown.
# AI Memory Log

## 2025-09-23T07:33:57+08:00 — Model: Cascade
- [memory_change]
  - action: create
  - id: b9c20371-f41b-4c46-a9db-e454f4b1e8a2
  - title: Switch auth persistence to Hive and store full account (AuthResponse)
  - tags: [auth, storage, hive, architecture, riverpod_generator]
  - content: Replaced shared_preferences-based auth persistence with Hive. Implemented Hive-backed AuthService storing full AuthResponse (tokens + account) via toJson/fromJson, initialized Hive in main.dart, updated AuthRepository.signIn to save full auth, adjusted AuthController to initialize from cached auth, and updated auth_service_provider to load cache synchronously. Login state is now determined by presence of cached AuthResponse in Hive.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.
- id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - user_triggered: false
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.
- id: 8e013dbd-7cff-4910-b964-045871a641d4
  - title: Shared ErrorMapper for centralized Dio/AppError mapping and unknown error wrapping
  - tags: [error_handling, architecture, dio, app_error, utility]
  - user_triggered: false
  - content: Created a shared ErrorMapper utility at lib/core/utils/error_mapper.dart to centralize mapping of DioException to AppError and wrapping unknown exceptions. Refactored ApiService and AuthRepository to use ErrorMapper, removing duplicated error mapping code. Standard guideline: repository and service layers should catch DioException and map via ErrorMapper, and catch all other exceptions and wrap as AppError.unknown.

## 2025-09-18T07:51:54+08:00 — Model: Cascade
- [memory_change]
  - action: create
  - id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.

## 2025-09-22T21:57:30+08:00 — Model: Cascade
- [memory_change]
  - action: create
  - id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.

## 2025-09-22T20:50:22+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.

## 2025-09-18T08:13:14+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.

## 2025-09-22T21:32:36+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.

## 2025-09-22T23:00:16+08:00 — Model: Cascade
- [memory_change]
  - action: create
  - id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.

## 2025-09-23T03:54:56+08:00 — Model: Cascade
- [memory_change]
  - action: create
  - id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.

## 2025-09-23T06:35:55+08:00 — Model: Cascade
- [memory_change]
  - action: create
  - id: 8e013dbd-7cff-4910-b964-045871a641d4
  - title: Shared ErrorMapper for centralized Dio/AppError mapping and unknown error wrapping
  - tags: [error_handling, architecture, dio, app_error, utility]
  - content: Created a shared ErrorMapper utility at lib/core/utils/error_mapper.dart to centralize mapping of DioException to AppError and wrapping unknown exceptions. Refactored ApiService and AuthRepository to use ErrorMapper, removing duplicated error mapping code. Standard guideline: repository and service layers should catch DioException and map via ErrorMapper, and catch all other exceptions and wrap as AppError.unknown.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.
- id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - user_triggered: false
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.
- id: 8e013dbd-7cff-4910-b964-045871a641d4
  - title: Shared ErrorMapper for centralized Dio/AppError mapping and unknown error wrapping
  - tags: [error_handling, architecture, dio, app_error, utility]
  - user_triggered: false
  - content: Created a shared ErrorMapper utility at lib/core/utils/error_mapper.dart to centralize mapping of DioException to AppError and wrapping unknown exceptions. Refactored ApiService and AuthRepository to use ErrorMapper, removing duplicated error mapping code. Standard guideline: repository and service layers should catch DioException and map via ErrorMapper, and catch all other exceptions and wrap as AppError.unknown.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.
- id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - user_triggered: false
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.

## 2025-09-23T06:29:41+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.
- id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - user_triggered: false
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.

## 2025-09-23T04:31:12+08:00 — Model: Cascade
- [memory_change]
  - action: none
  - note: No new memories added/updated/deleted for this step.

### Current Memory Snapshot
- id: 0b6cee5b-081d-4f40-8714-76671ddf3691
  - title: AI logging preference: maintain AI-log.md and AI-log-memories.md per prompt
  - tags: [workflow, logging, preference]
  - user_triggered: true
  - content: Always, for every prompt execution from now on, append an entry to AI-log.md (at repo root) including: model name (Cascade), local ISO8601 timestamp, the user prompt summary, and the actions taken. Also update AI-log-memories.md to reflect memory changes: log added/updated/deleted memories with timestamps and keep a current snapshot section.
- id: 2a4e96a7-b251-4fa9-a95b-a956c4687f2f
  - title: Auth scaffolding: models, services, repository, controller, HttpService header injection
  - tags: [auth, architecture, freezed, riverpod_generator, dio, config]
  - user_triggered: false
  - content: Added authentication scaffolding to palakat_admin Flutter project: Freezed models (AuthCredentials, AuthTokens, AuthResponse), AuthService for token persistence (shared_preferences), AuthRepository using Riverpod Generator and Dio, AuthController for login/logout, HttpService updated to inject Authorization header from AuthService, AppConfig extended with auth paths loaded from .env, and .env.example updated with AUTH_* endpoints.
- id: 392d2c18-9a7a-4d66-9f74-236f118f4c90
  - title: Centralize auth endpoints in AuthEndpoints class; remove AUTH_* from .env and AppConfig
  - tags: [auth, config, architecture, riverpod_generator, dio]
  - user_triggered: false
  - content: Centralized auth endpoint paths in a single Dart class `AuthEndpoints` (lib/core/config/auth_endpoints.dart) and removed AUTH_* endpoint variables from .env and AppConfig. Updated AuthRepository to use AuthEndpoints, and AppConfig no longer reads auth paths from environment.
- id: 77f7188f-8fe4-4510-b995-05ee8a42dadd
  - title: Fix circular dependency: HttpService refresh decoupled from AuthRepository; added AuthController.forceSignOut
  - tags: [auth, bugfix, riverpod_generator, dio, architecture]
  - user_triggered: false
  - content: Broke circular dependency in auth flow: removed authRepositoryProvider usage from http_service.dart and implemented direct token refresh with a lightweight Dio using AppConfig + AuthEndpoints + AuthService; added AuthController.forceSignOut() to clear tokens/state without hitting API for 401 handling.
