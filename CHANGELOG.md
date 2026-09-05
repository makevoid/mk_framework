# Changelog

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
`register_nested_resource` have been replaced. This version has not been published.
