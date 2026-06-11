# App Layer

This folder owns application wiring:

- app bootstrap
- top-level app shell
- route entry points
- scope / dependency injection boundaries

Keep this layer thin. Feature logic should live under `features/` or `domain/`.

