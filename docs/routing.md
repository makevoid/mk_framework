# Resource routing

## Deep resources

This declaration belongs in an application's `resource_routes` block. Parent
resources can use `only: []` when they exist only to scope child endpoints.

```ruby
scope '/api/v1' do
  resources :organizations, only: [] do
    resources :projects, only: [] do
      resources :comments
    end
  end
end
```

`PATCH /api/v1/organizations/one/projects/two/comments/three` dispatches to
`CommentsUpdateController` and `CommentsUpdateHandler` in the configured module.
The frozen path parameters are:

```ruby
{organization_id: 'one', project_id: 'two', id: 'three'}
```

Nested collection routes contain ancestor IDs but no leaf `id`. Arbitrary string
identifiers, including UUIDs and slugs, are supported; applications validate their
identifier formats. Query and JSON input cannot replace these captures.

The declarations describe URLs. Action files remain under `routes/comments/`.
Routing does not infer database associations or load parents automatically.

## Authentication and ownership

Use `before_request` for authentication shared by generated and native Roda routes:

```ruby
before_request do |r|
  # authenticate must verify the token/session and return a trusted user object.
  r.env['current_user'] = authenticate(r) or raise MK::Unauthorized
end
```

Load children through an authorized dataset in the controller:

```ruby
user = r.env.fetch('current_user')
organization = user.organizations_dataset
  .where(id: r.path_params.fetch(:organization_id)).first or raise MK::NotFound
project = organization.projects_dataset
  .where(id: r.path_params.fetch(:project_id)).first or raise MK::NotFound
comment = project.comments_dataset
  .where(id: r.path_params.fetch(:id)).first or raise MK::NotFound
```

Use that scoped lookup for reads, updates, and deletes. For creates, assign the
foreign key from the authorized parent, not from `r.input`. Database foreign keys
remain necessary to protect against concurrent deletion of a parent. Resource
ownership is separate from whether the user is allowed to perform an action;
enforce both. The blog and Kanban samples are public demonstrations, not account
systems. `spec/ownership_spec.rb` exercises authenticated three-level scoping.

## Shallow routes

```ruby
scope '/api/v1' do
  resources :posts do
    resources :comments, shallow: true
  end
end
```

Collections use `/api/v1/posts/:post_id/comments`; members use
`/api/v1/comments/:id`. There is no top-level comment collection and no nested
member route in this mode. Shallow members must still be loaded through the
authenticated user's authorized dataset. The shorter URL is not permission.

## Names, scopes, and actions

`scope '/api/v1'` changes the URL only. `namespace :admin` changes both the URL
prefix and the Ruby namespace (for example `Blog::Admin`). That module must exist
before route compilation. Use `namespace: SomeModule` on a resource to override
its action namespace without changing the URL.

```ruby
resources :people, singular: :person, parent_key: :owner_id do
  resources :user_profiles, param: :slug, only: %i[index show]
end
```

`param` names a member's own identifier. `parent_key` names the capture passed to
descendants. `singular` controls the default parent key and missing-resource label.
Basic inflection covers underscores, `companies`, and common irregular nouns;
set `singular` explicitly for domain terms. Repeated resources in one hierarchy
need distinct parent keys; duplicate parameter names fail at boot.

Custom actions can use any controller result, including service results without
a Sequel model:

```ruby
resources :posts do
  member :publish, via: :post
  collection :search, via: :get
end
```

This connects `PostsPublishController`/`PostsPublishHandler` to
`POST /posts/:id/publish`, and `PostsSearchController`/`PostsSearchHandler` to
`GET /posts/search`. Literal routes take precedence over identifier captures.

Pass `controller:` and `handler:` classes to custom actions, or override standard
actions with explicit class pairs:

```ruby
resources :posts, only: [:show], actions: {
  show: [PublicPostController, PublicPostHandler]
}
```

The full default action list is `index`, `show`, `create`, `update`, `delete`.
Missing actions, missing blocks, and duplicate method/path combinations fail at
boot. `App.route_table` prints the resolved paths and classes.

## Native Roda routes

An ordinary `route` block runs before generated routes. A matching Roda branch
or a non-nil return value completes the request; nil falls through to resources.

```ruby
route do |r|
  r.get('health') { {ok: true} }
  r.on('metrics') { r.run(metrics_app) }
end
```

Define routes, middleware, configuration, and hooks before `boot!`. The application
is frozen afterward; development changes require a process restart.
An unbooted shared application base can be subclassed: configuration, resource
declarations, and request hooks are inherited. Boot concrete applications only;
Roda does not allow subclassing an already frozen application.

## Nested writes

Nested URLs do not imply automatic nested assignment. Validate the payload and
allowlist each object's fields explicitly, then use one transaction:

```ruby
DB.transaction do
  project = persist(Project.new(project_attributes))
  validated_comment_attributes.each do |attributes|
    persist(Comment.new(attributes.merge(project_id: project.id)))
  end
  project
end
```

Authorize the parent before entering the transaction, bound the number of children,
and validate each child payload. Let validation exceptions escape the transaction
so it rolls back. External API calls are not rolled back with database writes;
perform them outside a database transaction or use an application-owned outbox.
