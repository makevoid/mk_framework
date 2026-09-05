# Kanban API with nested comments

A runnable MK Framework sample using the shared library at `../../lib`.
Its Ruby namespace is `SampleApp5` and its Rack entrypoint is `SampleApp5::App.app`.
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

Use the request specs and Rack entrypoint specs for local verification; do not
start the server directly while developing this sample.

## Endpoints

| Method | Path | Action |
| --- | --- | --- |
| GET / HEAD | `/cards` | List |
| POST | `/cards` | Create |
| GET / HEAD | `/cards/:id` | Show |
| PATCH / PUT | `/cards/:id` | Update supplied fields |
| DELETE | `/cards/:id` | Delete with model hooks |

The compatibility routes `POST /cards/:id` and `POST /cards/:id/delete`
remain available. Lists use `limit` (default 25, max 100) and `offset` (max 10,000).
JSON bodies must be objects. Only fields declared through `r.input.permit` reach
models. Validation errors return 422; missing resources return 404.

Comments support full CRUD under `/cards/:card_id/comments` and
`/cards/:card_id/comments/:id`. Member queries are scoped through their URL
parent, including updates and deletes. Child creation uses the URL parent ID even
when the client supplies a different one. Foreign keys enforce cascading deletion.

For compatibility, `/comments/:id` exposes show/update/delete with the same standard
verbs and POST aliases. There is no parentless `/comments` collection. These APIs
are public examples; add authentication and authorized parent datasets before using
them for private or multi-tenant data. URL nesting alone is not authorization.

Parent show responses contain a `card` object and a bounded `comments` array.
The same pagination settings apply to the embedded comments.

## Architecture

Controllers validate input, scope queries, and return prepared records. Framework
dispatch saves create/update results, destroys delete results with hooks, and
converts records and collections to raw hashes/arrays. Handlers filter and format
that data without querying or writing to the database. Models use Sequel;
CRUD samples maintain timestamps through its timestamps plugin. Request specs also
boot through the real `config.ru` from a different working directory.
