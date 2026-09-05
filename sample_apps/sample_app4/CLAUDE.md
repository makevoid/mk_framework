# Sample Application Guidelines

Follow the framework guidelines in [../../CLAUDE.md](../../CLAUDE.md).

Run `bundle exec rspec` from this directory; the tests use a private database.
Use `bundle exec rake db:migrate` for explicit development schema setup.

Do not run the server directly with `rackup` or `bundle exec rackup`.
Use RSpec request and Rack entrypoint specs for verification.
