# Sample Application Guidelines

Follow the framework guidelines in [../../CLAUDE.md](../../CLAUDE.md).

Run `bundle exec rspec` from this directory; the tests use a private database.
Use `bundle exec rake db:migrate` for explicit development schema setup.

Do not run the server directly with `rackup` or `bundle exec rackup`.
Use RSpec request and Rack entrypoint specs for verification.

Controllers use direct Sequel queries and return new, modified, or selected
records. Framework dispatch saves create/update results, destroys delete results,
and converts records/datasets (including those nested in hashes and arrays) into
raw data before handlers run. Do not manually save/destroy standard action results.
Select requested associations in controllers; handlers never receive Sequel objects.
Handlers filter raw attributes using the model class's `public_attributes_list`
and format responses. They must not issue queries or load associations.
