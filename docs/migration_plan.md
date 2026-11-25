# Warkop CKB Mobile Migration Plan

## Audit findings

- The workspace has no Git metadata, so source status cannot be reported. Both source projects are present and the target directory was absent during inspection.
- AINUL is the architecture and UI baseline: feature folders, typed product/cart/attendance models, location and camera helpers, shared colors, and existing cart/time tests.
- CICIL contributes the only observed REST contracts: `POST /login` with `identifier` and `password`, `GET /products`, `POST /orders`, and multipart `POST /attendance/check-in`. Product, order, and attendance response mapping lives in its API service. CICIL login itself bypasses this API and reads Supabase user tables and password hashes; that path is excluded.
- CICIL’s token is stored in SharedPreferences; the merged app will use secure storage. AINUL’s login has a prefilled sample password and submits to a local route; that sample credential and fake success flow will be removed.
- The UI in both projects contains hardcoded/demo values for employee schedule, profile, shift, and attendance dashboard. There are no corresponding REST contracts in the audited client. Preserve the screens and behavior without claiming these values are server-sourced.
- Management screens are not implemented. No management navigation destinations will be fabricated.
- No duplicate target exists. Platform templates are similar; AINUL’s identifier is `com.example.mobile_ckb`. CICIL declares internet permission and cleartext HTTP, while AINUL does not. The target will require Internet and location/camera permissions; cleartext will not be enabled by default.

## Migration decisions

- Scaffold `warkop_ckb_mobile/` independently; never write to `ainul/` or `cicil/`.
- Use AINUL UI, models, cart math, location acquisition, date formatting, and visual tokens as the baseline. Adapt them to English Dart naming and feature-oriented ownership.
- Implement one HTTP client, auth/session storage, typed repositories, and controllers for operations that have observed REST contracts. Preserve the CICIL payload keys and response compatibility aliases.
- Keep the outlet coordinates/radius as existing configuration values, but document that they are client-side checks and the backend must enforce them.
- Use a persistent indexed navigation shell and per-role configuration. Configure only implemented pages; preserve employee (attendance/schedule/profile) and cashier (POS/shift/profile) destinations. Add management only when real pages exist.
- Convert detail, verification, and success pages to routes outside the shell. Remove page-owned footers.
- Migrate native configuration selectively from generated scaffold, retaining the application identifier and enabling only required permissions.
- Add focused tests for navigation, API response mapping, session persistence contracts, and cart calculations. Run formatter, analyzer, tests, and Android debug build if the available SDK supports them.

## Work sequence

1. Scaffold isolated target and document audit/decisions.
2. Migrate AINUL UI/assets/models/services; rename English files and symbols; preserve Indonesian visible copy.
3. Add config, HTTP client, repositories, controller boundaries, secure session/token storage; remove direct Supabase and client-side password verification.
4. Introduce reusable layouts/theme/widgets and role-based persistent navigation; eliminate page-owned navigation.
5. Migrate CICIL REST-backed product/order/check-in behavior into typed repositories and connect the existing UI.
6. Add/adjust tests, format, analyze, run tests/build, and record any unavailable backend/platform requirements.
