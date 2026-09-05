# Blog API with nested comments

A runnable MK Framework sample using the shared library at `../../lib`.
Its Ruby namespace is `SampleApp4` and its Rack entrypoint is `SampleApp4::App.app`.
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
| GET / HEAD | `/posts` | List |
| POST | `/posts` | Create |
| GET / HEAD | `/posts/:id` | Show |
| PATCH / PUT | `/posts/:id` | Update supplied fields |
| DELETE | `/posts/:id` | Delete with model hooks |

The compatibility routes `POST /posts/:id` and `POST /posts/:id/delete`
remain available. Lists use `limit` (default 25, max 100) and `offset` (max 10,000).
JSON bodies must be objects. Only fields declared through `r.input.permit` reach
models. Validation errors return 422; missing resources return 404.

Use `GET /posts?comments=1` to include a `comments` array in each post:

```sh
http :9292/posts comments==1
http :9292/posts comments==1 limit==10 offset==0
```

Without `comments=1`, the index returns only post attributes. Comments are eagerly
loaded in one additional query; posts without comments include an empty array.
`limit` and `offset` paginate posts only. The index includes all comments for each
selected post; use the nested comments endpoint when you need paginated comments.

Comments support full CRUD under `/posts/:post_id/comments` and
`/posts/:post_id/comments/:id`. Member queries are scoped through their URL
parent, including updates and deletes. Child creation uses the URL parent ID even
when the client supplies a different one. Foreign keys enforce cascading deletion.

For compatibility, `/comments/:id` exposes show/update/delete with the same standard
verbs and POST aliases. There is no parentless `/comments` collection. These APIs
are public examples; add authentication and authorized parent datasets before using
them for private or multi-tenant data. URL nesting alone is not authorization.

Parent show responses contain a `post` object and a bounded `comments` array.
The same pagination settings apply to the embedded comments.

## Architecture

Controllers validate input and use direct Sequel queries. Create actions return a
new model; updates assign permitted fields and return the model; deletes return
the selected model. Framework dispatch automatically calls `save` for create/update
or `destroy` for delete, then converts the record's `values` to raw data. Show/index
results are materialized without writes. Validation and constraint/hook failures
become 422 and 409 responses before a handler runs.

`r.page` validates pagination parameters; controllers apply ordering and limits.
Controllers also select requested associations. The framework recursively converts
records and datasets nested in hashes/arrays before passing the result to handlers;
it does not save nested records or implicitly load associations.

A handler's `model` is raw response data, never a Sequel model or dataset. Handlers
only filter fields using `Post.public_attributes_list` /
`Comment.public_attributes_list` and format responses; they must not query, load
associations, save, or delete. The index handler filters the supplied `:comments`
array without consulting request parameters. Request specs verify this boundary
and check that every handler executes without SQL.

Models use Sequel;
CRUD samples maintain timestamps through its timestamps plugin. Request specs also
boot through the real `config.ru` from a different working directory.
