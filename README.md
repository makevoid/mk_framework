# MK Framework

Small, explicit JSON APIs on [Roda](https://roda.jeremyevans.net/), with optional
[Sequel](https://sequel.jeremyevans.net/) persistence. Ruby 3.2 or newer. MIT licensed.

MK gives each action an obvious home:

```text
app.rb
models/post.rb
routes/posts/controllers/create.rb
routes/posts/handlers/create.rb
```

Controllers select and prepare records. Framework dispatch persists standard action
results and converts them to raw data. Handlers filter fields and format responses.
Authorization, association selection, and multi-record transactions remain explicit Ruby.
You can read the core in `lib/mk_framework/`; no ORM or database is loaded until you
require `mk_framework/sequel`.

## Install

Available on [RubyGems](https://rubygems.org/gems/mk_framework) and the
[RubyGems index](https://index.rubygems.org/gems/mk_framework).

```sh
gem install mk_framework -v 0.2.5
```

Or add it to your application's Gemfile:

```ruby
source 'https://rubygems.org'
gem 'mk_framework', '~> 0.2.5'
```

Run `bundle install`. Add `sequel` and your database driver if you use
`mk_framework/sequel`; both are optional application dependencies.

## Generate an app with `mk_frame_init`

Version 0.2.5 generates full CRUD apps with the `mk_frame_init` executable. Install the gem, then run
it from the parent directory where you want your new app:

```sh
gem install mk_framework -v 0.2.5
mk_frame_init
```

RubyGems puts `mk_frame_init` in Ruby's executable directory. Inside a bundle that
includes MK, you can also run `bundle exec mk_frame_init`.

The interactive CLI asks, in order:

1. App name, such as `blog` (Ruby namespace `Blog`).
2. Singular model name, such as `post` (`Blog::Post`).
3. Resource/table name, defaulting to `posts`.
4. Each field name and its type, selected by menu number or type name. Leave the
   next field name blank to finish.
5. Confirmation of the app, model, fields, resource actions, and destination.

Use lowercase names with underscores. The supported types are `string`, `text`,
`integer`, `float`, `boolean`, `date`, and `datetime`. At least one field is required;
all selected fields are required. MK generates `id`, `created_at`, and `updated_at`
automatically. Date/time inputs use ISO 8601 strings, and numeric inputs use JSON
numbers. Invalid field types return 400; missing required fields or blank text
return 422.

For scripts and automation, supply the whole definition in a quoted `--cli`
argument. This mode never prompts or asks for confirmation:

```sh
mk_frame_init --cli 'app_name:blog, model_name:posts, fields:[title:string, contents:text, published:boolean]'
```

This creates `./blog`, a `Blog::Post` model backed by `posts`, and full CRUD routes:
`GET /posts`, `GET /posts/:id`, `POST /posts`, `PATCH /posts/:id`, `PUT /posts/:id`,
and `DELETE /posts/:id`. Each action has its own controller and handler. Inline
`model_name` accepts a singular or conventional plural name (`post` or `posts`).
For a custom table/URL name, add `resource_name:articles`. Names are simple Ruby
identifiers; the inline format is parsed as data, never evaluated as Ruby.

An optional destination overrides the default app directory. Its parent must
already exist, and the generator refuses existing destinations, including empty
directories. Invalid input exits with status 1; successful generation exits with 0.
No dependencies are installed and no database is opened during generation.

```sh
mk_frame_init ./blog_api --cli 'app_name:blog, model_name:posts, fields:[title:string, contents:text]'
mk_frame_init --help
```

After generation:

```sh
cd blog_api
bundle install
bundle exec rake db:migrate
bundle exec rake routes
bundle exec rspec
bundle exec rake        # same as rake dev; starts Puma on port 3000
```

Set `HOST` or `PORT` to override the default `127.0.0.1:3000` bind address.

The result is self-contained:

```text
blog_api/
├── Gemfile
├── Rakefile
├── .gitignore
├── README.md
├── database.rb
├── app.rb
├── config.ru
├── db/migrations/001_initial.rb
├── models/post.rb
├── routes/posts/controllers/{index,show,create,update,delete}.rb
├── routes/posts/handlers/{index,show,create,update,delete}.rb
├── spec/spec_helper.rb
└── spec/request/posts_spec.rb
```

`database.rb` connects to a local SQLite file, or `DATABASE_URL`. Migrations are
explicit and run before models load. Tests always migrate a private in-memory
database. The controller permits the chosen fields and returns `Post.new(...)`;
MK saves once, then the handler returns `{post: ...}` with status 201. Index returns
`{posts: [...]}` with bounded `limit`/`offset` pagination; show, update, and delete return `{post: ...}` with status 200.
PATCH and PUT preserve omitted fields; missing records return 404. The generated
README includes a local server command, an example request, and extension guidance.

The framework checkout also exposes the same generator as a Rake task:

```sh
bundle exec rake mk_framework:init DESTINATION=./blog_api
bundle exec rake mk_framework:init DESTINATION=./blog_api \
  APP_SPEC='app_name:blog, model_name:posts, fields:[title:string, contents:text]'
```

These are alternative invocations; choose one for a new destination. To expose the
task in another project's Rakefile, add `require 'mk_framework/generator/tasks'`.

## Try the sample applications

The published [sample applications repository](https://github.com/makevoid/mk_framework_sample_apps)
contains 33 runnable pairs of JSON APIs and MkFrame frontends. Each app has its own
`sample_appNN/api/` and `sample_appNN/ui/` directories. Browse the
[app catalog](https://github.com/makevoid/mk_framework_sample_apps/blob/main/Readme.md)
to choose one; each app's `Readme.md` gives its setup and launch commands.
The APIs use the published `mk_framework` gem from RubyGems, so no framework
source checkout is required.

To run [sample 04, Fieldnotes](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app04/Readme.md)
with its UI:

```sh
git clone https://github.com/makevoid/mk_framework_sample_apps.git
cd mk_framework_sample_apps
bundle install
cd sample_app04
bundle exec rake setup
bundle exec rake dev
```

Open the UI at `http://127.0.0.1:5184/`; its API listens at
`http://127.0.0.1:9404`. `setup` installs the API and UI dependencies, migrates
the database, and seeds demo data. Later starts only need `bundle exec rake dev`.
Run `bundle exec rake spec` from `sample_app04` for its API request specs.

From the sample repository root, follow the API's
[API README](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app04/api/README.md):

```sh
cd sample_app04/api
bundle install
bundle exec rake db:seed
bundle exec rake routes
bundle exec rake dev
```

The API-only server defaults to `http://127.0.0.1:3000`. `db:seed` applies the
migration explicitly before loading fixtures; server boot never migrates or seeds.
The API README documents endpoints, data rules, deployment settings and tests.

### Study sample 04's request flow

The [post creation controller](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app04/api/routes/posts/controllers/create.rb)
permits `title` and `description` and returns a new `Post`. MK saves the record;
the [handler](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app04/api/routes/posts/handlers/create.rb)
selects public fields and sets status 201. The
[post index controller](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app04/api/routes/posts/controllers/index.rb)
selects and paginates records, optionally eager loading comments; its
[handler](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app04/api/routes/posts/handlers/index.rb)
formats the selected data. The
[nested comment update controller](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app04/api/routes/comments/controllers/update.rb)
looks up a comment through its URL parent before assigning permitted fields.
The [request specs](https://github.com/makevoid/mk_framework_sample_apps/tree/main/sample_app04/api/spec/request)
exercise those behaviors and check that handlers perform no SQL.

## Controllers prepare; the framework persists; handlers respond

In sample 04, controllers own queries, input assignment, and access rules;
handlers own public fields, status, and response shape.
`Post.public_attributes_list` and `Comment.public_attributes_list` are
application-defined field lists. The sample's `handler_boundary_spec.rb` checks
that every handler runs without issuing SQL.

Requiring `mk_framework/sequel` enables this lifecycle for a controller's returned
Sequel model, using the registered route action:

| Action | Before the handler |
| --- | --- |
| create | `save`, then `values` |
| update | `save`, then `values` |
| delete | `destroy` with hooks, then `values` |
| show | `values` |
| index | Materialize the collection and convert records to `values` |

Create controllers return `Post.new(...)`; updates find a record and call `set(...)`;
deletes return the record to delete. Do not save or destroy these results manually.
PATCH/PUT and POST compatibility aliases share the same lifecycle. Custom action
names do not automatically write, regardless of their controller class name.
Validation failures return 422; expected constraint/hook conflicts return 409;
unexpected database failures reach the sanitized 500 handler.

Records and datasets nested in hashes/arrays are recursively converted to raw data,
without recursively saving or deleting them. Controllers explicitly select any
associations to include; conversion does not load associations implicitly. Handlers
receive hashes and arrays, filter them with `fields` or `slice` and a model's
`public_attributes_list`, and never query the database.

Plain hash/array results remain usable for service-backed actions. For related
writes, use `DB.transaction` and explicit saves (or `MK::Persistence` helpers), then
return raw data so the framework does not save a completed write again.

Handlers return a Hash or Array, or use
`r.halt` for an explicit response such as 204. Returning `nil` from a controller
means the resource was not found.
Inside action blocks, use `next` for an early result; Ruby's `return` would try to
return from the context where the block was originally defined.

## Routes and HTTP

For `resources :posts`, MK registers:

| Method | Path | Action |
| --- | --- | --- |
| GET / HEAD | `/posts` | index |
| POST | `/posts` | create |
| GET / HEAD | `/posts/:id` | show |
| PATCH / PUT | `/posts/:id` | update |
| DELETE | `/posts/:id` | delete |

PUT and PATCH reach the same action; the sample controllers update only supplied
fields. Define a separate custom action if your API needs strict replacement
semantics. The old `POST /posts/:id` and `POST /posts/:id/delete` routes remain
enabled by default. Disable them with `configure legacy_post_routes: false`.
Known paths with unsupported methods return 405 and `Allow`; unknown paths return
404. CORS preflights are application policy, not automatically enabled.

Read [nested routes and authorization](docs/routing.md) for scopes, namespaces,
shallow routes, custom actions, explicit class mappings, and parent ownership.

## Working with the request (`r`)

`r` is the current Roda request, extended with MK's input and pagination helpers.
Controllers use `route do |r|` to load records and prepare changes; handlers use
`handler do |r|` to format the resulting raw data and choose a response status.
The snippets below belong inside the application's namespace, after defining its
models. Define routes and configuration before calling `App.boot!`.

### Declare routes

Inside your `MK::Application` subclass:

```ruby
configure root: ROOT, namespace: Blog, legacy_post_routes: false

resource_routes do
  resources :posts do
    resources :comments
  end
end
```

`resources :posts` maps the CRUD URLs in the table above to
`PostsIndexController`/`PostsIndexHandler`, `PostsShowController`/`PostsShowHandler`,
and the corresponding create, update and delete pairs. Files live under
`routes/posts/controllers/` and `routes/posts/handlers/`. Nested comments still
use action files under `routes/comments/`; nesting changes the URL, not the files.

Restrict actions or add a named endpoint explicitly:

```ruby
resource_routes do
  resources :posts, only: %i[index show] do
    member :publish, via: :post
  end
end
```

The member action maps `POST /posts/:id/publish` to
`PostsPublishController` and `PostsPublishHandler`. Supply both classes before
boot. Custom actions do not automatically save their returned models; persistence
must be explicit. Inspect the compiled mapping with `puts App.route_table`.

### URL identifiers: `r.path_params`

For `PUT /posts/12/comments/34`, the nested declaration captures:

```ruby
r.path_params # => { post_id: '12', id: '34' }
```

This is a frozen hash with symbol keys and string values. IDs may be slugs or
UUIDs; MK does not coerce them to integers. Collection routes contain parent IDs
but no member `:id`. Body and query fields cannot overwrite these captures.

Load a nested record through its parent in the controller:

```ruby
route do |r|
  post = Post[r.path_params.fetch(:post_id)] or raise MK::NotFound
  comment = post.comments_dataset.where(id: r.path_params.fetch(:id)).first
  raise MK::NotFound unless comment

  comment.set(r.input.permit(content: String))
end
```

The URL describes the relationship; it does not load or authorize a parent.
In an authenticated app, first scope the parent query to the current user's
allowed records. Assign foreign keys from that parent, not from client input.

### Body and query fields: `r.input`

Use `permit` to select fields and validate their types. It returns a symbol-keyed
hash, drops unknown fields, and omits fields the client did not send:

```ruby
route do |r|
  attributes = r.input.permit(
    title: String,
    description: [String, NilClass],
    published: :boolean
  )
  Post.new(attributes)
end
```

`permit` does not require a field to be present. Model validation can reject a
missing title with 422 when MK saves the returned model. A present value of the
wrong type raises `MK::BadRequest` (400). `NilClass` explicitly permits JSON null;
`String` alone does not. Length, uniqueness and other domain rules belong in the
model or controller. Nested objects are not recursively allowlisted for you.

For a required input, call `require` (its default type is `String`):

```ruby
query = r.input.require(:query)
quantity = r.input.require(:quantity, type: Integer)
```

A missing key or invalid type returns 400. An empty string still has type String;
check whether it is meaningful in your application. `Integer` accepts a JSON
integer, not the query string `"3"`. Use the integer helper for numeric query
parameters or form fields:

```ruby
quantity = r.input.integer(:quantity, default: 1, min: 1, max: 20)
```

This accepts integers and strings of decimal digits, applies the default only
when the field is absent, and returns 400 for invalid values or bounds. It does
not silently clamp them. `:boolean` accepts JSON `true`/`false` and the strings
`"true"`, `"false"`, `"1"`, `"0"`; false is retained in permitted attributes.
Dates arrive as strings: parse them explicitly, as the CLI's date fields do.

`r.input` reads body/query input separately from path captures. The compatibility
`r.params` hash combines input with string-keyed path captures, and path values
win on collision. Prefer `r.path_params` for identity and `r.input` for attributes.

### Bounded pagination: `r.page`

For `GET /posts?limit=10&offset=20`, `r.page` returns
`{ limit: 10, offset: 20 }`. Apply it to an ordered query:

```ruby
route do |r|
  page = r.page
  Post.order(:id).limit(page[:limit], page[:offset])
end
```

The helper validates parameters; it does not query the database or add response
metadata. Defaults are `limit: 25` and `offset: 0`. Allowed limits are 1–100 and
allowed offsets are 0–10,000. Invalid inputs return 400. Override the bounds in
the application before boot:

```ruby
configure page_size: 20, max_page_size: 50, max_offset: 5_000
```

All three settings must be positive integers, and `page_size` cannot exceed
`max_page_size`. Controllers that include `MK::Persistence` can instead use
`paginate(Post.dataset, r)`, which orders by `id`, applies these bounds and returns
an array. For large datasets, implement cursor pagination in your application.

### Response status, headers and early returns

Handlers receive prepared raw data through `model` and return hashes or arrays.
MK serializes the response; do not call `to_json` in a handler:

```ruby
handler do |r|
  r.response.status = 201
  r.response['location'] = "/posts/#{model.fetch(:id)}"
  { post: model.slice(:id, :title) }
end
```

Use an MK error for an intentional failure such as `raise MK::NotFound` or
`raise MK::Forbidden`. Use `r.halt` when you need an explicit early response:

```ruby
r.halt(409, { error: 'Post is already published' })
```

Request-scoped application data can be stored in `r.env`, for example a verified
user set by `before_request`. Native Roda routes also work and run before resource
routes; return `nil` when they should fall through:

```ruby
route do |r|
  r.get('health') { { ok: true } }
  nil
end
```

See [the routing guide](docs/routing.md) for authentication hooks, scopes,
namespaces, shallow routes and custom action mappings.

## Errors and request limits

JSON bodies must be objects. Malformed JSON and malformed query inputs produce
400. Bodies above 1 MiB produce 413, including bodies without a content length;
`max_body_bytes` configures the limit.

`MK::BadRequest`, `MK::Unauthorized`, `MK::Forbidden`, `MK::NotFound`,
`MK::Conflict`, `MK::ValidationError` and `MK::BadGateway` represent intentional
public errors. Their messages are public, so never put secrets in them.
Unexpected errors return JSON with `error: "Server error"` and a request ID.
The same ID appears in `X-Request-ID` and the structured error log.

Production is the safe default. Set `RACK_ENV=development` explicitly for debug
details. Configure a logger using `configure logger: Logger.new($stdout)`, or
`setup_logger(io)`. `configure filter_parameters: %w[ssn]` adds fields to the
built-in recursive redaction list. Production logs omit raw exception messages
because database and network exceptions can contain credentials or SQL values.

## Release and deployment

```sh
bundle exec rake
bundle exec rake build
```

The gem is written to `pkg/mk_framework-0.2.5.gem`. See
[deployment](docs/deployment.md) for migrations, connections, authentication,
timeouts, logging, and release verification, and [upgrading](docs/upgrading.md)
for changes from the prototype. CI runs on Ruby 4.0 on Linux.

Applications can optionally `require 'mk_framework/testing'` and include
`MK::Framework::Spec` in RSpec to use Rack::Test and the `resp` JSON helper.
Install `rack-test` separately in the application's test bundle.
