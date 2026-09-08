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

```sh
gem install mk_framework -v 0.2.0
```

Or add it to your application's Gemfile:

```ruby
source 'https://rubygems.org'
gem 'mk_framework', '~> 0.2.0'
```

Run `bundle install`. Add `sequel` and your database driver if you use
`mk_framework/sequel`; both are optional application dependencies.

## Try the examples

The seven sample applications live in
[mk_framework_sample_apps](https://github.com/makevoid/mk_framework_sample_apps)
and install MK from RubyGems. Both GitHub repositories are private; installing the
published gem does not require access to the framework repository.

From a sample-app checkout:

```sh
git clone git@github.com:makevoid/mk_framework_sample_apps.git
cd mk_framework_sample_apps/sample_app4
bundle install
bundle exec rake db:migrate      # Explicit schema setup; never done on server boot
bundle exec rake routes
bundle exec rspec
```

All sample tests force `RACK_ENV=test` and use private in-memory SQLite databases.
They never open `DATABASE_URL` or the development SQLite files. The weather tests
stub HTTP and require no personal API key or internet connection.

| Sample | Demonstrates |
| --- | --- |
| [1](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app1/README.md) | Basic todos and JSON CRUD |
| [2](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app2/README.md) | Todo validation and request specs |
| [3](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app3/README.md) | Custom response envelopes |
| [4](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app4/README.md) | Blog posts, nested comments, parent scoping |
| [5](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app5/README.md) | Kanban cards, status validation, nested comments |
| [6](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app6/README.md) | Weather client, deadlines, atomic cache refresh |
| [7](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app7/README.md) | Three-column Kanban board, ordering, priorities, filters, archive and comments |

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

## Controllers prepare; the framework persists; handlers respond

These action files assume your application has explicitly required its `Post`
model, backed by a migrated Sequel dataset, before calling `boot!`.

```ruby
require 'mk_framework/sequel'

module Blog
  class PostsCreateController < MK::Controller
    route do |r|
      Post.new(r.input.permit(title: String, description: [String, NilClass]))
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

The gem is written to `pkg/mk_framework-0.2.0.gem`. See
[deployment](docs/deployment.md) for migrations, connections, authentication,
timeouts, logging, and release verification, and [upgrading](docs/upgrading.md)
for changes from the prototype. CI covers Ruby 3.2, 3.3, 3.4, and 4.0 on Linux.

Applications can optionally `require 'mk_framework/testing'` and include
`MK::Framework::Spec` in RSpec to use Rack::Test and the `resp` JSON helper.
Install `rack-test` separately in the application's test bundle.
