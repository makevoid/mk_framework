# Todo API

A runnable MK Framework sample using the shared library at `../../lib`.
Its Ruby namespace is `SampleApp1` and its Rack entrypoint is `SampleApp1::App.app`.
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
| GET / HEAD | `/todos` | List |
| POST | `/todos` | Create |
| GET / HEAD | `/todos/:id` | Show |
| PATCH / PUT | `/todos/:id` | Update supplied fields |
| DELETE | `/todos/:id` | Delete with model hooks |

The compatibility routes `POST /todos/:id` and `POST /todos/:id/delete`
remain available. Lists use `limit` (default 25, max 100) and `offset` (max 10,000).
JSON bodies must be objects. Only fields declared through `r.input.permit` reach
models. Validation errors return 422; missing resources return 404.


## Architecture

Controllers validate input, scope queries, and explicitly persist records. Handlers
format JSON with an explicit field list and do not save or delete. Models use Sequel;
CRUD samples maintain timestamps through its timestamps plugin. Request specs also
boot through the real `config.ru` from a different working directory.
