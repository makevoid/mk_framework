# Weather API

A runnable MK Framework sample using the shared library at `../../lib`.
Its Ruby namespace is `SampleApp6` and its Rack entrypoint is `SampleApp6::App.app`.
See [the framework README](../../README.md) and [routing guide](../../docs/routing.md).

## Setup and tests

From this directory:

```sh
bundle install
bundle exec rake db:migrate
bundle exec rake routes
bundle exec rspec
```

Migrations are explicit; loading the application does not create tables. The default
SQLite database is inside this directory. `DATABASE_URL`, `DB_POOL_SIZE`, and
`DB_POOL_TIMEOUT` configure deployment connections. Tests always use private
in-memory databases, apply migrations there, and never open a development database.

After migration, `RACK_ENV=production bundle exec rackup` loads `config.ru`.

## Endpoints

| Method | Path | Action |
| --- | --- | --- |
| GET / HEAD | `/weather` | List cached locations with pagination |
| GET / HEAD | `/weather/:location` | Fetch or reuse a one-hour cache entry |

Set `OPENWEATHERMAP_API_KEY` for live requests. The app does not read personal key
files. An uncached request without a key returns 503. Unknown locations return
404; upstream failures return a sanitized 502. Connect/read/write deadlines are
3/5/5 seconds. Cache refresh uses a unique location index and atomic upsert.

Responses use `forecast`, containing eight three-hour periods (24 hours), plus
`location`, `fetched_at`, and `cache_expires_at`. Timestamps include a timezone.
The old `hourly_forecast` field was inaccurate and has been removed.

Tests stub HTTP with WebMock, check the exact query parameters, use a dummy key,
and prohibit network connections. They exercise fresh/expired cache, missing keys,
upstream errors, formatting, and pagination without sleeping or random data.

## Architecture

Controllers validate input, scope queries, and explicitly persist records. Handlers
format JSON with an explicit field list and do not save or delete. Models use Sequel;
CRUD samples maintain timestamps through its timestamps plugin. Request specs also
boot through the real `config.ru` from a different working directory.
