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

Controllers do application work. Handlers format responses. The router connects
them. Writes, transactions, authorization, and response fields remain explicit Ruby.
You can read the core in `lib/mk_framework/`; no ORM or database is loaded until you
require `mk_framework/sequel`.

## Try the examples

From this checkout:

```sh
bundle install
bundle exec rake                 # Framework tests and all six sample suites
cd sample_apps/sample_app4
bundle exec rake db:migrate      # Explicit schema setup; never done on server boot
bundle exec rake routes
bundle exec rspec
```

All sample tests force `RACK_ENV=test` and use private in-memory SQLite databases.
They never open `DATABASE_URL` or the development SQLite files. The weather tests
stub HTTP and require no personal API key or internet connection.

| Sample | Demonstrates |
| --- | --- |
| [1](sample_apps/sample_app1/README.md) | Basic todos and JSON CRUD |
| [2](sample_apps/sample_app2/README.md) | Todo validation and request specs |
| [3](sample_apps/sample_app3/README.md) | Custom response envelopes |
| [4](sample_apps/sample_app4/README.md) | Blog posts, nested comments, parent scoping |
| [5](sample_apps/sample_app5/README.md) | Kanban cards, status validation, nested comments |
| [6](sample_apps/sample_app6/README.md) | Weather client, deadlines, atomic cache refresh |

## An application

Define classes in your own module. Configure an absolute root, then call `boot!`
after the class definition. Boot loads route files, resolves action classes, checks
the route table, and freezes application configuration before serving requests.

```ruby
require 'mk_framework'

module Blog
  class App < MK::Application
    configure root: __dir__, namespace: Blog

    resource_routes do
      resources :posts do
        resources :comments
      end
    end
  end

  App.boot!
end
```

In `config.ru`:

```ruby
require_relative 'app'
run Blog::App.app
```

By convention, `posts/create` connects `Blog::PostsCreateController` to
`Blog::PostsCreateHandler`. Without a `resource_routes` block, MK discovers the
standard action files under `routes/*/controllers`; explicit declarations are
recommended for APIs with nested or custom routes. Missing handlers fail at boot.

## Controllers write; handlers respond

These action files assume your application has explicitly required its `Post`
model, backed by a migrated Sequel dataset, before calling `boot!`.

```ruby
require 'mk_framework/sequel'

module Blog
  class PostsCreateController < MK::Controller
    include MK::Persistence

    route do |r|
      persist Post.new(r.input.permit(title: String, description: [String, NilClass]))
    end
  end

  class PostsCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {post: fields(model, :id, :title, :description)}
    end
  end
end
```

`persist` saves once and translates model validation to 422 and constraint conflicts
to 409. `destroy(record)` invokes Sequel destroy hooks. Database failures reach the
application's sanitized 500 handler. These helpers are optional; controllers can
call ordinary Ruby services. Use `DB.transaction` around related writes.

Handlers can receive any controller result. They return a Hash or Array, or use
`r.halt` for an explicit response such as 204. Returning `nil` from a controller
means the resource was not found. There is no class-name-based persistence behavior.
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

## Inputs, responses, and errors

- `r.path_params` is a frozen symbol-keyed hash containing only URL captures.
- `r.input` validates body/query input independently of path IDs. `require(:name)`
  requires a typed field; `permit(name: String)` allows only declared fields.
- `:boolean` accepts booleans and the form strings `true`, `false`, `1`, `0`.
  Nullable fields must explicitly include `NilClass` in their accepted types.
- `r.params` remains compatible with older controllers, with path IDs taking
  precedence. Never use client input to establish a parent relationship.
- `r.page` validates `limit` (default 25, maximum 100) and `offset` (maximum 10,000).
  `paginate(dataset, r)` in `MK::Persistence` uses an ordered, bounded query.
  Implement cursor pagination in your application when large offsets are needed.
- JSON request bodies must be objects. Malformed JSON and malformed query inputs
  produce 400. Bodies above 1 MiB produce 413, including bodies without a length.
- `MK::BadRequest`, `Unauthorized`, `Forbidden`, `NotFound`, `Conflict`,
  `ValidationError`, and `BadGateway` represent intentional public errors.
  Their messages are public: never place secrets in them.
- Unexpected errors return JSON with `error: "Server error"` and a request ID.
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

The gem is written to `pkg/mk_framework-0.1.0.gem`. See
[deployment](docs/deployment.md) for migrations, connections, authentication,
timeouts, logging, and release verification, and [upgrading](docs/upgrading.md)
for changes from the prototype. CI covers Ruby 3.2, 3.3, 3.4, and 4.0 on Linux.

Applications can optionally `require 'mk_framework/testing'` and include
`MK::Framework::Spec` in RSpec to use Rack::Test and the `resp` JSON helper.
Install `rack-test` separately in the application's test bundle.
