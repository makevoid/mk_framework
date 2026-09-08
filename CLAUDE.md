# MK Framework Guidelines

## Commands
- Install the root bundle: `bundle install`
- Run framework tests: `bundle exec rake`
- Run framework specs: `bundle exec rspec spec`
- Build the gem: `bundle exec rake build`

## Design and style
- Include `# frozen_string_literal: true` in Ruby files.
- Always put spaces inside nonempty Ruby hash braces, including generated code: `{ post: model }`. Keep empty hashes as `{}`.
- Use small Ruby blocks and explicit requires; keep classes in an application module.
- Configure an absolute root and namespace, then call `App.boot!` after defining the app.
- Controllers own data access, authorization, attribute assignment, and explicit multi-record transactions.
- Return a Sequel model from standard create/update/delete actions: framework dispatch calls save/save/destroy once, then converts it to raw attributes. Show/index results are only materialized.
- Handlers receive raw hashes and arrays, filter fields, and format responses/statuses; they never query, save, delete, or load associations.
- Use `handler do |r|` for response blocks and `route do |r|` for controllers.
- Handlers return Hash/Array values; use `r.halt` for explicit early HTTP responses. Do not call `to_json` in handlers.
- Require `mk_framework/sequel` for automatic action persistence and raw data conversion. Include `MK::Persistence` only for pagination or explicit transactions; after explicit writes return raw data to avoid a second lifecycle write.
- Use `r.path_params` for URL identifiers and `r.input` for allowlisted typed body/query fields.
- Scope nested member lookups and writes through the authorized parent.
- Use Sequel migrations and private test databases. Never create tables during server boot.
- Test real PATCH/PUT/DELETE behavior and retained POST compatibility routes.
- Add meaningful regression tests for changed behavior and propagate child test failures.
- Use the README and docs for the current API; `success`/`error` persistence blocks and
  `register_nested_resource` belong to the old prototype and are no longer supported.
