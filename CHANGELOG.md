# Changelog

## 0.2.2 — 2026-09-08

- Generate full CRUD resources: index, show, create, update (PATCH and PUT), and
  delete, with separate controllers and handlers for every action.
- Make generated apps' default `rake` task invoke `rake dev` and start Puma on
  `127.0.0.1:3000`, with `HOST` and `PORT` overrides.
- Include generated request specs for reads, partial updates, deletion, missing
  records, validation failures, and persistence; verify all supported field types.
- Store generated-app timestamps in UTC so datetime updates round-trip consistently.
- Update generator prompts, next steps, and documentation for the complete app.

## 0.2.1 — 2026-09-08

- Add `mk_frame_init` with interactive prompts and a non-interactive `--cli`
  definition for generating a self-contained app, model, create controller/handler,
  migration, Rack entrypoint, and request specs.
- Add the reusable `mk_framework:init` Rake task and seven supported field types.
- Document standalone sample support and the generator installation and CLI flows.
- Run the Linux CI tests and gem build on Ruby 4.0 only.

## 0.2.0 — 2026-09-08

- Release MK as an installable gem with standalone framework tests and packaging.
- Move all seven sample applications, their shared support, and integration tests
  to [mk_framework_sample_apps](https://github.com/makevoid/mk_framework_sample_apps).
  Applications depend on `mk_framework ~> 0.2.0` from RubyGems.
- Remove application-only development dependencies and legacy test-helper paths
  from the framework repository.

## 0.1.0 — unreleased

- Package MK as an MIT-licensed gem, with a standalone test suite and Ruby 3.2–4.0 CI.
- Compile an immutable resource tree at explicit application boot. Add deep nesting,
  shallow routes, namespaces, custom actions, action allowlists, configurable IDs,
  route inspection, HEAD, PATCH, PUT, DELETE, and 405/Allow responses.
- Preserve POST update/delete URLs as configurable compatibility aliases.
- Persist returned Sequel records by registered action before response handlers:
  create/update save once, delete invokes destroy hooks, show/index materialize data.
  Handlers receive raw hashes/arrays; explicit multi-record transactions remain available.
- Add typed input allowlists, bounded pagination and request bodies, request IDs,
  resilient JSON errors, recursive parameter redaction, and request hooks.
- Scope and namespace the sample applications. Add migrations, test-only databases,
  deterministic weather tests, boot checks, and relationship/persistence regressions.
- Correct the weather entrypoint, explicitly require Excon, bound upstream timeouts,
  atomically refresh cached locations, and label three-hour forecasts accurately.
- Update dependencies, documentation, and the aggregate test runner.

### Migration required

See [the upgrade guide](docs/upgrading.md). The implicit handler persistence API and
`register_nested_resource` have been replaced. The 0.1.0 prototype was not published; these changes first ship in 0.2.0.
