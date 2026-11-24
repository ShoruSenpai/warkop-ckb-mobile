# Warkop CKB Mobile

Flutter application merging the AINUL interface foundation with verified REST integrations from CICIL. The original projects remain untouched.

## Run locally

Configure the backend URL at build time; no API host is embedded in the app:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://your-api-host
```

The backend must implement the observed CICIL contracts: `POST /login`, `GET /products`, `POST /orders`, and multipart `POST /attendance/check-in`. Login must return an access token and a user object with a role recognizable as management, cashier, or employee. Other profile, schedule, shift, and management API contracts were not present in either Flutter source and are not simulated as backend features.

Authentication tokens and persisted user session data are stored with `flutter_secure_storage`.

See [the migration plan](docs/migration_plan.md) and [the technical report](docs/migration_report.md) for migration decisions, validation status, and maintenance guidance.
