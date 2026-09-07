# Offgrid

Offline-first places and notes. SQLite is the source of truth; changes sync when the device is back online. This is a Clean Architecture / sync sample, not an OCR or expiry app.

## Status

Scaffold (7 Sep 2026): Flutter app and Clean Architecture layers. Place/Note entities and SQLite come on later weekdays.

## Layout

```
lib/core/error          Failure types
lib/core/usecase        Use-case contract
lib/domain/repositories Abstract offline repository
lib/data/datasources    Local vs remote contracts
lib/presentation/pages  UI
```

## Run

```bash
flutter pub get
flutter run
```

## v1 target

Add a place or note offline, list it, sync when online, unit + widget tests, GitHub Actions.
