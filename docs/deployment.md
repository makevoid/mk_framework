# Deployment and release

MK supplies routing, explicit action dispatch, JSON errors, and request boundaries.
Authentication policies, schema design, external services, and process operation
belong to the application. The APIs in the separate
[example repository](https://github.com/makevoid/mk_framework_sample_apps) are
demonstrations without authentication.

## Configuration

Set `RACK_ENV=production` explicitly in deployments; it is also MK's default when
the variable is absent. Debug details are enabled only for `development`.

Configure the app before `boot!`:

```ruby
configure root: __dir__, namespace: MyApp,
          logger: Logger.new($stdout),
          filter_parameters: %w[ssn access_code],
          max_body_bytes: 1_048_576,
          page_size: 25, max_page_size: 100, max_offset: 10_000
```

Boot eagerly loads route files and freezes route/configuration state before
requests. Restart after code changes. Controller and handler instances are created
per request. Avoid mutable class variables for request data; use local variables,
instance variables, or the Rack request environment.

## Database lifecycle

The samples accept `DATABASE_URL`, `DB_POOL_SIZE` (default 5), and
`DB_POOL_TIMEOUT` (default 5 seconds). Without a URL they use a SQLite file under
the sample directory, independent of the current working directory. Tests always
use private in-memory databases, regardless of these environment variables.

Run migrations once as a release step before starting workers. Keep backups and
test restore procedures. Do not put schema changes in app boot or request code.
Sample migrations use Sequel's migration version table and fail on an unexpected
pre-existing schema; the upgrade guide covers prototype databases.

For another adapter, install its driver explicitly and test the migrations and
queries against that adapter. The local automated suite exercises SQLite; it does
not certify PostgreSQL/MySQL behavior. Size the pool for the server's request
threads and the total number of worker processes within the database connection
budget. Use explicit transactions for related writes and retain database-level
foreign keys, uniqueness constraints, and indexes.

When preloading and forking a server, disconnect Sequel connections before fork
so child processes do not inherit live connections. Sequel reconnects on demand.
Apply this to every database owned by your app. The samples expose their database
as `SampleAppN::DB`. Test the specific Puma worker configuration you deploy;
Rack entrypoint specs do not exercise process forking.

The sample models update timestamps through Sequel's timestamps plugin. SQL writes
outside those models must set timestamps themselves. Do not use unbounded `.all`
queries in endpoints; use `paginate` or application-specific cursor pagination.

## Authentication, browser clients, and limits

Use Rack/Roda authentication middleware or `before_request` to validate credentials
and establish a trusted principal. Apply authorization in controllers to both
resource ownership and the requested action. Never trust a query/body tenant ID.
See the routing guide and `spec/ownership_spec.rb` for an executable scoping test.

For session/cookie authentication, add CSRF protection and appropriate secure,
HTTP-only, same-site cookie settings using the corresponding Roda plugins.
For cross-origin clients, explicitly allow trusted origins, headers, and methods
through your chosen CORS middleware. MK does not enable permissive CORS or infer
authorization from URL nesting.

Terminate TLS at the server or a trusted proxy. Configure trusted host/proxy
handling for your deployment, especially before generating absolute URLs or
trusting forwarded client addresses. Set proxy/server header and request timeouts,
connection limits, and rate limits. MK's body cap bounds buffered request memory;
it is not a timeout or a rate limiter. File streaming APIs should use a separately
configured/mounted application with an appropriate body policy.

External HTTP clients need connect/read/write deadlines. The weather example uses
3/5/5 seconds and atomic cache upserts. Its cache does not implement distributed
request coalescing: simultaneous misses can make redundant upstream requests, but
cannot create duplicate location rows. Add quotas/coalescing where upstream costs
or traffic justify it.

## Logs and observability

Each request gets a server-generated `X-Request-ID`. Unexpected failures write a
structured JSON event through the configured logger, with the same identifier,
error class, stack, and recursively filtered already-parsed parameters. Production
logs omit raw exception messages and model values. A failed log sink does not
replace the error response. Add domain-specific sensitive keys to the filter.

Intentional public errors are not logged as unexpected failures. Collect access
logs, latency, request counts, status counts, database pool pressure, and readiness
checks with your server/middleware/monitoring stack. Apply redaction to those logs
too: external middleware is not covered by MK's parameter filter. Log retention
and access permissions are deployment decisions.

## Release procedure

1. Run `bundle install` and `bundle exec rake` with frozen lockfiles in CI.
2. Require the Linux Ruby matrix to pass before publishing. Local results on one
   Ruby version are not a substitute for that matrix.
3. Run `bundle exec rake build`. Inspect and install the generated gem in a clean
   environment, including `require 'mk_framework'` without Sequel and the optional
   `require 'mk_framework/sequel'` with its dependency installed.
4. Test the production app entrypoint against a newly migrated test database and
   your intended server/proxy configuration. Test existing-data upgrades separately.
5. Update the version/changelog and publish the reviewed gem using an authorized
   RubyGems account. The gem metadata requires MFA. No publish task runs automatically.

CI runs framework/request tests and builds the gem on Ruby 3.2, 3.3, 3.4, and 4.0.
The framework root `rake` command runs its standalone specs. The separate sample
repository runs its integration tests and all seven application suites against the
published gem, isolating Bundler Gemfile and lockfile paths for each child and
propagating failures.
