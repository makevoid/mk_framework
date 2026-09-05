# MK Framework Guidelines

## Commands
- Install the root bundle: `bundle install`
- Run framework and all sample suites: `bundle exec rake`
- Run framework specs: `bundle exec rspec spec`
- Run a sample suite from its directory: `bundle exec rspec`
- Apply a sample's migrations: `bundle exec rake db:migrate`
- Inspect a sample's compiled routes: `bundle exec rake routes`
- Build the gem: `bundle exec rake build`

## Design and style
- Include `# frozen_string_literal: true` in Ruby files.
- Use small Ruby blocks and explicit requires; keep classes in an application module.
- Configure an absolute root and namespace, then call `App.boot!` after defining the app.
- Controllers own data access, authorization, persistence, and transaction boundaries.
- Handlers format responses and statuses; they never implicitly save or delete models.
- Use `handler do |r|` for response blocks and `route do |r|` for controllers.
- Return Hash/Array values; use `r.halt` for explicit early HTTP responses. Do not call `to_json` in handlers.
- Require `mk_framework/sequel` and include `MK::Persistence` for explicit persistence helpers.
- Use `r.path_params` for URL identifiers and `r.input` for allowlisted typed body/query fields.
- Scope nested member lookups and writes through the authorized parent.
- Use Sequel migrations and private test databases. Never create tables during server boot.
- Test real PATCH/PUT/DELETE behavior and retained POST compatibility routes.
- Add meaningful regression tests for changed behavior and propagate child test failures.
- Use the README and docs for the current API; `success`/`error` persistence blocks and
  `register_nested_resource` belong to the old prototype and are no longer supported.
