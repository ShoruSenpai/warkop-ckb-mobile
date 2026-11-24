# Warkop CKB Mobile ? Technical Migration Report

## A. Project migration

- New isolated project: `warkop_ckb_mobile/`.
- `ainul/` and `cicil/` were preserved. Their Git working trees were clean at inspection; the new target is not inside a Git repository.
- AINUL supplied the Flutter/platform scaffold, visual styling, employee attendance screens, location/camera flow, employee profile and schedule screens, typed product/cart models, cart math, and date/time helpers.
- CICIL supplied the observed REST contract details for login, products, order submission, and multipart attendance check-in. Its Supabase password lookup and SharedPreferences token path were not migrated.
- Internal Dart paths and symbols were reorganized under `app/`, `core/`, and `features/` using English names. Indonesian user-facing labels remain.
- `pubspec.yaml` removes Supabase, bcrypt, and nonessential SharedPreferences use; adds the HTTP client and secure storage; and retains the location, image, formatting, and visual dependencies. The inherited `pubspec.lock` could not be regenerated because package resolution failed (see Validation).
- Android package identifier remains `com.example.mobile_ckb`. Internet, camera, and location permissions are declared; cleartext traffic is not enabled for release.
- The order success page now displays backend response data; it no longer claims unsent print or messaging actions succeeded.

## B. Architecture

```text
lib/
??? main.dart
??? app/
?   ??? app.dart, app_dependencies.dart
?   ??? router/                 # route names, routing, role guards
?   ??? navigation/             # item model, role configuration, footer
?   ??? shells/                 # persistent role shell
?   ??? session/                # current user, auth session, session manager
??? core/
?   ??? config/                 # environment-driven API configuration
?   ??? network/                # API interface, HTTP client, results/errors, auth
?   ??? storage/                # secure token/session storage
?   ??? theme/                  # shared colors, dimensions, theme
?   ??? layouts/                # app, detail, and fullscreen layouts
?   ??? widgets/                # buttons, cards, fields, badges, dialogs, states
?   ??? utils/
??? features/
    ??? auth/                   # login page/controller and repository
    ??? cashier/pos/            # POS controller, models, cart service, repositories
    ??? cashier/orders/         # order success page
    ??? cashier/shift/          # shift screen
    ??? employee/               # attendance, profile, and schedule screens
```

Pages render and collect input. Controllers coordinate page actions. Feature services handle cart and location rules. Repositories map backend data and use `ApiClient`; only the HTTP client performs network requests. Shared components live in `core`; one-feature components remain with that feature.

The larger migrated attendance, profile, schedule, shift, and verification screens still contain some presentation-local state and layout code. The primary network-backed flows (login, POS loading/order submission, attendance submission) have controllers/repositories, but a complete extraction of every large screen into small widgets/view models remains future cleanup. Static schedule/profile/shift demo content from the sources is still present and must not be treated as backend data.

## C. Navigation

- `RoleNavigationConfig` centrally defines labels, routes, icons, and allowed roles.
- Employee footer: Absensi, Jadwal, Profil. Cashier footer: POS, Tukar Shift, Profil; POS is first. Management currently has no implemented destinations and receives an unavailable-state message rather than fake entries.
- `MainAppShell` owns one footer and uses `IndexedStack` so tabs retain widget state. `CashierAppShell` reuses this shell. Detail, camera, location, and success pages are routed outside the shell.
- Route access is checked by `route_guards.dart`; inaccessible destinations redirect to that role?s landing route.
- Add an implemented page by creating its feature page and route, adding a `NavigationItem` to the appropriate list in `RoleNavigationConfig`, and mapping that route to the page there. Remove or reorder entries in the same role list. A new role needs a `UserRole` value, explicit role landing route/guard policy, and a configuration list; the shared shell and footer do not need rewriting.

The navigation uses `IndexedStack` rather than `go_router` because it is implemented without adding a router dependency and preserves tab widget state. Nested per-tab route history is not implemented; detail routes currently use the root navigator.

## D. Backend integration

- No Supabase SDK, Supabase initialization/client, direct table access, BCrypt verification, credentials, or hardcoded API host remains in the target Flutter source/dependencies.
- `HttpApiClient` centralizes JSON and multipart HTTP, bearer authorization, timeout/network handling, API status mapping, and 401 session clearing.
- `API_BASE_URL` is injected with `--dart-define`; endpoints are centralized in `AppConfig`.
- Implemented repositories: `AuthRepository`, `ProductRepository`, `OrderRepository`, `AttendanceRepository`.
- Login calls `POST /login` with `identifier` and `password`; accepted response shapes expect a token/access token plus a user object. Password verification is delegated to the backend.
- Products use `GET /products`; orders use `POST /orders`; attendance uses multipart `POST /attendance/check-in` with latitude, longitude, and photo fields. Order/attendance totals and success state come from the response where available; local cart totals are estimates only.
- `flutter_secure_storage` stores the token and serialized session identity. A 401 clears the session.
- Contracts for profile, schedule, shift management, and management dashboards were not present in the source clients. No endpoints or success behavior were invented. Backend owners still need to confirm login response keys/role vocabulary, API base path conventions, exact order payload/response fields, attendance upload field names, and server-side location/price validation.
- Outlet coordinates/radius are client-side location checks carried forward from CICIL. The backend must independently enforce attendance eligibility.

## E. Validation

- Formatting: `dart format .` completed; 70 Dart files inspected, two reformatted. It warned that `flutter_lints` could not be resolved before dependency installation.
- Pure Dart analysis of session role mapping, network result/client interfaces, config/storage abstractions, product/cart models and services, and repositories: **passed** (`No issues found`).
- Relative import scan: **passed**, no broken relative imports found.
- Supabase/password-hash scan: **passed**, no matching references in `lib/` or `pubspec.yaml`.
- Dependency installation: **blocked**. `dart pub get` could not reach pub.dev and could not resolve packages; Flutter commands also hit an SDK cache lock permission issue because the installed SDK is outside the writable workspace.
- Full `flutter analyze`, `flutter test`, and debug build: **not completed**. Tests have been added/updated for navigation configuration, session behavior, product mapping, attendance validation, API repositories, cart math, and time helpers, but have not been executed. No test/build success is claimed.
- Since package resolution was blocked, full Flutter type analysis and platform compilation remain important before release. The lockfile must be regenerated with `flutter pub get` in an environment with a writable SDK and package access.

## F. Future maintenance guide

1. **Create a page:** add it inside the owning `features/<feature>/presentation/pages/` folder and register its route in `RouteNames` and `AppRouter`.
2. **Separate UI and logic:** keep rendering and input handling in the page; move page state/actions into a controller; put reusable business rules in a domain service; put backend mapping and calls in a repository.
3. **Create reusable components:** put cross-feature components in `core/widgets/` or shared layout/theme code in `core/`; keep feature-only components beside their feature.
4. **Add a footer destination:** add a `NavigationItem` for an existing page to the desired role list in `RoleNavigationConfig` and add its page mapping there.
5. **Remove/change a destination:** edit that one role list?s item, label, icon, or order; update route/guard only if the page itself is also removed or access changes.
6. **Add a role:** add the role to `UserRole`, map its backend role value and landing route, define its allowed route policy, and add a config list in `RoleNavigationConfig`. The shared navigation widget and shell remain reusable.
