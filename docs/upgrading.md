# Upgrading from the prototype

0.2.0 changes the Ruby API while retaining the original POST mutation URLs by
default. Upgrade application code before using the new gem. The six samples have
already been migrated.

## Application boot and class names

Place models, controllers, handlers, and the app in an application module. In each
file, declare that module explicitly; `require` does not inherit its caller's
lexical namespace. Configure `root: __dir__` and `namespace: YourApp` in the app,
and call `YourApp::App.boot!` after its class definition.

Models must be loaded before boot. MK loads action files relative to the configured
root and resolves action classes there. `boot!` validates and freezes the app;
calling `app` before boot is an error. Configure middleware and plugins beforehand.
Restart the process to pick up source changes.

The samples now expose `SampleApp1::App` through `SampleApp6::App` instead of global
`TodoApp`, `BlogApp`, `KanbanApp`, and `WeatherApp` classes. Their model datasets are
explicit, so multiple sample apps can coexist without sharing constants or data.

## Automatic action persistence and raw handler data

Previously, handlers interpreted class-name suffixes and saved/deleted the object
returned by a controller. Remove handler `success`/`error` registration blocks.
Controllers return the prepared record; framework dispatch persists it according
to the registered action and converts it to raw attributes before the handler:

```ruby
# Controller
route do |r|
  Post.new(r.input.permit(title: String))
end

# Handler
handler do |r|
  r.response.status = 201
  {post: fields(model, :id, :title)}
end
```

Require `mk_framework/sequel` for this lifecycle. Sequel is optional and must be
listed in your application's Gemfile. Create/update results receive `save` then
`values`; delete results receive `destroy` then `values`; show/index results are
converted without writes. Remove explicit `persist`, `save`, and `destroy` calls
from standard controllers to avoid duplicate writes. For explicit multi-record
transactions, return raw data after completing the writes. Custom actions do not
automatically persist records.

Handlers receive raw hashes/arrays, including materialized nested results. Replace
model attribute/association methods with hash access and allowlist filtering.
Select associations in controllers. A handler does not query or write under any
action name. Validation uses 422 for
both create and update; expected constraint conflicts use 409. Unexpected failures
are sanitized 500s. Deliberate `MK::Error` messages are public.

The old `route` declaration in a handler remains an alias for `handler`, but it
does not move persistence into handlers. Handlers return Hash/Array responses rather
than calling `to_json`. For an empty success, use `r.halt(204)` in the handler.

## Resource declarations

Replace `register_nested_resource` with a resource tree:

```ruby
resource_routes do
  resources :posts do
    resources :comments
  end
  # Optional compatibility URLs for the old shallow member endpoints:
  resources :comments, only: %i[show update delete]
end
```

This exposes fully nested CRUD plus the explicitly requested shallow members.
For exclusively shallow members, instead use `resources :comments, shallow: true`
inside the parent. There are no implicit parentless comment collections.

Use `r.path_params` for ancestor and member IDs. Existing `r.params['id']` remains
supported, but `r.input` deliberately contains only query/body input. `r.params`
gives URL IDs precedence. Scope all nested member lookups through their parent.

PATCH, PUT, and DELETE now work. POST update/delete aliases remain on by default;
turn them off using `configure legacy_post_routes: false` when clients migrate.

## Database migration

Server boot no longer creates tables. On a new database, run the sample's
`bundle exec rake db:migrate` before loading its app. Tests use their own in-memory
databases and run migrations there.

Do not run the initial migration blindly against a populated prototype database:
the existing tables will cause it to fail rather than be silently adopted or
replaced. Back up that database, compare its schema with `db/migrations/001_initial.rb`,
and write an application-specific upgrade migration or import into a freshly
migrated database. Backfill null timestamps and missing defaults before adding
the new constraints. Mark the initial migration applied only after confirming
schema equivalence. No existing database is automatically altered by this upgrade.

## Responses and clients

Lists are bounded to 25 records by default; use `limit` and `offset`. Maximum limit
is 100 and maximum offset is 10,000. Nested comments included in parent show
responses use the same bounds. Adapt clients that previously expected every row.

The weather API uses `OPENWEATHERMAP_API_KEY`, not a file in the user's home. Its
response field is now `forecast`, containing eight three-hour periods, replacing
the inaccurate `hourly_forecast` field. Times include a timezone. Upstream failures
are sanitized 502 responses; an unknown location is 404; a missing key is 503.

Missing-resource responses consistently use an `error` field. Unexpected error
responses also include a request ID. Do not depend on internal exception messages.

## Tests and dependencies

Use `bundle exec rake` at the repository root to test the framework and every
sample in isolated processes. Child failures fail the aggregate task. Sample tests
force `RACK_ENV=test`; they do not open development databases or `DATABASE_URL`.

Install the updated bundles with Ruby 3.2 or later and the locked Bundler version.
The lockfiles include updates to Roda, Rack, Sequel, SQLite3, Puma, and test tools.
Puma moved from 6.x to 8.x; review your own server configuration when upgrading.
See `docs/deployment.md` for deployment and release checks.
