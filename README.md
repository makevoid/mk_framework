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
gem install mk_framework -v 0.2.3
```

Or add it to your application's Gemfile:

```ruby
source 'https://rubygems.org'
gem 'mk_framework', '~> 0.2.3'
```

Run `bundle install`. Add `sequel` and your database driver if you use
`mk_framework/sequel`; both are optional application dependencies.

## Generate an app with `mk_frame_init`

Version 0.2.3 generates full CRUD apps with the `mk_frame_init` executable. Install the gem, then run
it from the parent directory where you want your new app:

```sh
gem install mk_framework -v 0.2.3
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

## Try the examples

Twenty paired sample applications (JSON APIs and MkFrame frontends) live in
[mk_framework_sample_apps](https://github.com/makevoid/mk_framework_sample_apps)
and install MK from RubyGems. Each sample has its own README, database migrations
and isolated request specs. Backend use does not require a framework source checkout.

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
| [5](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app5/README.md) | Kanban cards, validation, nested comments |
| [6](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app6/README.md) | Weather client, deadlines, atomic cache refresh |
| [7](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app7/README.md) | Kanban board, ordering, priorities, filters, archive and comments |
| [8](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app8/README.md) | Single-user ecommerce, product image uploads and a persistent cart |
| [9](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app9/README.md) | Fictional electric car inventory, charging specs and reservations |
| [10](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app10/README.md) | Buildlog developer journal, project portfolio and private publishing workbench |
| [11](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app11/README.md) | Rolecraft job board, employer submissions, moderation and private applications |
| [12](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app12/README.md) | Reboot Market electronics classifieds, photo uploads, private inquiries, saved searches and moderation |
| [13](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app13/README.md) | Pinpoint map directory, geographic filters, contributor history and transactional approval |
| [14](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app14/README.md) | Studio Hours timed resource bookings, Zurich availability, maintenance and transactional conflict prevention |
| [15](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app15/README.md) | Pantry Table recipes, private meal plans, pantry stock and derived shopping quantities |
| [16](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app16/README.md) | Assembly community events, workshop capacity, FIFO waitlists, organizer management and check-in |
| [17](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app17/README.md) | Fairshare private expense groups, exact splits, receipts, balances and reimbursements |
| [18](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app18/README.md) | Signalboard feedback, voting, moderation, duplicate merges, roadmap and releases |
| [19](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app19/README.md) | Night Archive NASA discovery, private collections and observing journal |
| [20](https://github.com/makevoid/mk_framework_sample_apps/blob/main/sample_app20/README.md) | Fieldwork private plant collection, care schedules and growth journals |

## Walkthrough: sample app 4, a blog API

[Sample app 4](https://github.com/makevoid/mk_framework_sample_apps/tree/main/sample_app4)
stores posts and their comments in SQLite and exposes JSON CRUD endpoints. A post
has a title and optional description; a comment belongs to a post and has content
and an optional author. Both models maintain creation and update timestamps.
Deleting a post also deletes its comments through a cascading foreign key.

Clients can list posts, request their comments with `GET /posts?comments=1`, create
a post with `POST /posts`, and edit a comment with
`PATCH /posts/:post_id/comments/:id`. Nested comment lookups check the URL parent,
so using another post's ID returns 404. This sample has no authentication;
parent scoping checks the relationship, while user access rules belong in your app.

### Directory structure

The samples share database and Rake helpers in the repository-level `support/`
directory. Keep that directory when copying a sample; use the CLI above for a
self-contained starter. This tree lists
the six action files explained below; the sample also includes the remaining CRUD
controllers and handlers for both resources.

```text
sample_app4/
├── Gemfile
├── Rakefile
├── database.rb              # SampleApp4::ROOT and SampleApp4::DB
├── app.rb                   # Requires, namespace, routes, and boot!
├── config.ru                # Rack entrypoint
├── db/migrations/
│   └── 001_initial.rb       # posts, comments, indexes, and foreign key
├── models/
│   ├── post.rb
│   └── comment.rb
├── routes/
│   ├── posts/
│   │   ├── controllers/
│   │   │   ├── create.rb
│   │   │   └── index.rb
│   │   └── handlers/
│   │       ├── create.rb
│   │       └── index.rb
│   └── comments/
│       ├── controllers/update.rb
│       └── handlers/update.rb
└── spec/
    ├── spec_helper.rb
    ├── boot_spec.rb
    └── request/
        ├── posts_spec.rb
        ├── comments_spec.rb
        ├── nested_comments_spec.rb
        └── handler_boundary_spec.rb
```

### Setup, database, and boot

The sample's `Gemfile` includes the framework, Sequel, SQLite, Rack server tools,
and request-test dependencies:

```ruby
source 'https://rubygems.org'

gem 'mk_framework', '~> 0.2.2'
gem 'sequel', '>= 5.92', '< 6'
gem 'sqlite3', '~> 2.9'
gem 'rake', '~> 13.4'
gem 'rackup', '~> 2.3'
gem 'puma', '~> 8.0'

group :test do
  gem 'rspec', '~> 3.13'
  gem 'rack-test', '~> 2.2'
end
```

From `mk_framework_sample_apps/sample_app4`, run:

```sh
bundle install
bundle exec rake db:migrate
bundle exec rake routes
bundle exec rspec
```

`Rakefile` loads `../support/tasks.rb` and installs the shared tasks with
`SampleTasks.install(__dir__)`.
`db:migrate` loads `database.rb` and applies `db/migrations/001_initial.rb` before
any models are loaded. The migration creates `posts` and `comments`, including
required timestamps and a non-null `comments.post_id` foreign key with cascading
deletion. Schema changes are an explicit step; starting the app never migrates it.

**`sample_app4/database.rb`**

```ruby
# frozen_string_literal: true

require_relative '../support/database'

module SampleApp4
  ROOT = __dir__.freeze
  DB = SampleDatabase.connect(root: ROOT, filename: 'blog.db')
end
```

`SampleDatabase.connect` defaults to `sample_app4/blog.db`, using an absolute path.
It accepts `DATABASE_URL`, `DB_POOL_SIZE`, and `DB_POOL_TIMEOUT` for deployment.
In tests it always opens a private in-memory SQLite database; `spec_helper.rb`
migrates that database before requiring `app.rb`.

**`sample_app4/app.rb`**

```ruby
# frozen_string_literal: true

require 'mk_framework/sequel'
require_relative 'database'
require_relative 'models/post'
require_relative 'models/comment'

module SampleApp4
  class Controller < MK::Controller
  end

  class App < MK::Application
    configure root: ROOT, namespace: SampleApp4

    resource_routes do
      resources :posts do
        resources :comments
      end
      resources :comments, only: %i[show update delete]
    end
  end

  App.boot!
end
```

The load order is deliberate: enable MK's Sequel integration, connect the database,
load both models, define the shared controller base and application, then call
`App.boot!`. `ROOT` anchors file loading independently of the working directory;
`namespace: SampleApp4` tells MK where to resolve controller and handler classes.

The nested declaration generates post and comment CRUD routes. The final
`resources :comments, only: ...` also exposes the sample's compatibility member
routes, such as `PATCH /comments/:id`; it does not create a parentless comments
collection. Both forms use the same comment action classes.

`boot!` loads Ruby files under `routes/`, resolves controller/handler pairs,
validates the route table, and freezes configuration. For example,
`posts/create` resolves to `SampleApp4::PostsCreateController` and
`SampleApp4::PostsCreateHandler`. Missing handlers fail at boot. Without a
`resource_routes` block, MK can discover standard actions from
`routes/*/controllers`; explicit declarations make nested routes easier to inspect.

**`sample_app4/config.ru`**

```ruby
# frozen_string_literal: true

require_relative 'app'
run SampleApp4::App.app
```

Rack loads this entrypoint and serves the already booted `SampleApp4::App.app`.
The sample's request and boot specs exercise it without starting a server,
including loading it from a different working directory.

### Example 1: create a post

`POST /posts` accepts a JSON object such as
`{"title":"First post","description":"Notes from the garden"}`.

**`sample_app4/routes/posts/controllers/create.rb`**

```ruby
# frozen_string_literal: true

module SampleApp4
  class PostsCreateController < Controller
    route do |r|
      Post.new(r.input.permit(title: [String, NilClass], description: [String, NilClass]))
    end
  end
end
```

The controller permits only `title` and `description` and returns an unsaved
`Post`. Strings and null are accepted at the input boundary; the model requires a
nonblank title of at most 100 characters. Missing or null titles therefore reach
model validation and return 422. Unexpected input types return 400.

MK recognizes the `create` action, saves the returned model once, and converts
its attributes to a hash before invoking the handler.

**`sample_app4/routes/posts/handlers/create.rb`**

```ruby
# frozen_string_literal: true

module SampleApp4
  class PostsCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Post created', post: model.slice(*Post.public_attributes_list)}
    end
  end
end
```

The response is 201 with a `message` and a `post` object containing only the fields
in `Post.public_attributes_list`: `id`, `title`, `description`, `created_at`, and
`updated_at`. The handler neither saves the model nor serializes JSON itself.

**Evolve it:** add a nullable `slug` column and a unique index in a new migration,
then add slug validation in `models/post.rb`, permit `slug` in create/update
controllers, and include it in `Post.public_attributes_list` if clients need it.
A generated slug belongs in a model hook or controller. Keep the handler focused
on the response, and extend `spec/request/posts_spec.rb` to cover creation,
validation, and duplicate slugs.

### Example 2: list posts with optional comments

`GET /posts?comments=1&limit=10&offset=0` returns up to ten posts with their comments.
Omit `comments=1` to return only post attributes.

**`sample_app4/routes/posts/controllers/index.rb`**

```ruby
# frozen_string_literal: true

module SampleApp4
  class PostsIndexController < Controller
    route do |r|
      page = r.page
      posts = Post.order(:id).limit(page[:limit], page[:offset])
      posts = posts.eager(:comments) if r.params['comments'] == '1'
      posts.all.map do |post|
        attributes = post.values.dup
        if r.params['comments'] == '1'
          attributes[:comments] = post.comments
        end
        attributes
      end
    end
  end
end
```

`r.page` validates pagination. Posts have a stable ID order, a default page size
of 25, a maximum of 100, and an offset limit of 10,000. When requested, Sequel
loads comments eagerly in one additional query, avoiding a separate query per
post. The controller selects associations explicitly and returns their data;
MK recursively converts the nested comment models to hashes.

**`sample_app4/routes/posts/handlers/index.rb`**

```ruby
# frozen_string_literal: true

module SampleApp4
  class PostsIndexHandler < MK::Handler
    handler do |r|
      model.map do |post|
        attributes = post.slice(*Post.public_attributes_list)
        if post.key?(:comments)
          attributes[:comments] = post.fetch(:comments).map { |comment| comment.slice(*Comment.public_attributes_list) }
        end
        attributes
      end
    end
  end
end
```

The response is a JSON array. A post includes `comments` only when the controller
supplied that key; posts without comments then have `comments: []`. The handler
filters each supplied hash and performs no queries. Pagination bounds the number
of posts here, but includes all comments for those posts. Use
`GET /posts/:post_id/comments?limit=10&offset=0` for a paginated comment collection.

**Evolve it:** add a `published` boolean in a migration and validate/permit it in
the model and write actions. For a public feed, start the index query from
`Post.where(published: true)` before ordering, pagination, and eager loading.
Apply the same publication policy to show and comment routes. An authenticated
editor view can select a broader dataset in its controller; handlers can keep the
same response shape. Extend the index specs to check which posts are visible and
that including comments still uses two queries for a nonempty page.

To evolve the response into `{posts: [...], pagination: {...}}`, have the controller
return the selected posts and pagination metadata together, then update the handler
to filter the posts and build that envelope. Any total-count query belongs in the
controller. Update client expectations and request specs for the changed shape,
and keep the handler's no-SQL check.

### Example 3: update a comment through its post

`PATCH /posts/12/comments/34` with `{"content":"An updated reply"}` changes only
comment 34 belonging to post 12. Unspecified fields, such as `author`, retain
their stored values.

**`sample_app4/routes/comments/controllers/update.rb`**

```ruby
# frozen_string_literal: true

module SampleApp4
  class CommentsUpdateController < Controller
    route do |r|
      comments = Comment.where(id: r.path_params.fetch(:id))
      if (post_id = r.path_params[:post_id])
        post = Post[post_id]
        raise MK::NotFound, 'Post not found' unless post

        comments = post.comments_dataset.where(id: r.path_params.fetch(:id))
      end
      comment = comments.first
      raise MK::NotFound, 'Comment not found' unless comment

      comment.set(r.input.permit(content: [String, NilClass], author: [String, NilClass]))
      comment
    end
  end
end
```

On a nested route, the controller first finds the post, then selects the comment
through `post.comments_dataset`. A missing post or a comment belonging to another
post returns 404. Only `content` and `author` can be assigned; a body `post_id`
cannot move the comment. The parentless compatibility route uses the initial
comment lookup instead.

`comment.set` assigns the permitted fields without writing. Returning the model
lets MK save it once for the `update` action, validate it, update its timestamp,
and hand raw attributes to the handler. Blank content fails validation with 422.

**`sample_app4/routes/comments/handlers/update.rb`**

```ruby
# frozen_string_literal: true

module SampleApp4
  class CommentsUpdateHandler < MK::Handler
    handler do |r|
      {message: 'Comment updated', comment: model.slice(*Comment.public_attributes_list)}
    end
  end
end
```

The successful response is 200 with `message` and a `comment` object containing
`id`, `post_id`, `content`, `author`, `created_at`, and `updated_at`.

**Evolve it:** for per-user editing, authenticate the request and select the post
from the signed-in user's authorized dataset before selecting its comment. Add
any separate comment-edit permission check in the controller. Remove the
parentless `resources :comments, only: ...` declaration if edits must always use
a post URL, or apply equivalent authorization to that branch. Extend
`spec/request/nested_comments_spec.rb` to cover another user's post, a wrong URL
parent, and a spoofed body `post_id`, confirming denied writes leave data intact.
The handler can remain unchanged.

## Controllers prepare; the framework persists; handlers respond

The three pairs above share the same boundary: controllers own queries, input
assignment, and access rules; handlers own public fields, status, and response
shape. `Post.public_attributes_list` and `Comment.public_attributes_list` are
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

The gem is written to `pkg/mk_framework-0.2.3.gem`. See
[deployment](docs/deployment.md) for migrations, connections, authentication,
timeouts, logging, and release verification, and [upgrading](docs/upgrading.md)
for changes from the prototype. CI runs on Ruby 4.0 on Linux.

Applications can optionally `require 'mk_framework/testing'` and include
`MK::Framework::Spec` in RSpec to use Rack::Test and the `resp` JSON helper.
Install `rack-test` separately in the application's test bundle.
