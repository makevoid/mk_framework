# MK Framework Guidelines

## Commands
- Run server: `bundle exec rackup`
- Install dependencies: `bundle install`
- Run tests: `bundle exec rspec`
- Run single test: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Linting: `bundle exec rubocop`

## Code Style
- Include `# frozen_string_literal: true` at the top of each Ruby file
- Follow Ruby naming conventions: snake_case for methods/variables, CamelCase for classes
- RESTful architecture with controller/handler separation
- Controllers handle data retrieval and business logic
- Handlers handle response formatting and HTTP status
- Models use Sequel::Model with validation_helpers plugin
- Error handling: use r.halt for interrupting execution, handlers for formatting errors
- Resource routing follows RESTful convention (index, show, create, update, delete)
- Keep methods small and focused on a single responsibility
- Explicit requires over autoloading
- Use fetch for required parameters, direct access for optional ones

## HTTP Method Conventions
- Framework uses non-standard HTTP method conventions for some operations
- DELETE operations use POST to "/:resource/:id/delete" instead of DELETE method
- UPDATE operations use POST to "/:resource/:id" instead of PUT/PATCH
- Test both standard (delete "/todos/:id") and framework-specific (post "/todos/:id/delete") methods
- Do not standardize HTTP methods across tests as this dual approach validates both patterns

## Route Structure
- Framework uses a consistent RESTful routing pattern similar to Ruby on Rails and Sinatra:
  - GET /todos - index (list all)
  - GET /todos/:id - show (get one)
  - POST /todos - create
  - POST /todos/:id - update
  - POST /todos/:id/delete - delete


## Gotchas when developing with the MK framework

There are some gotchas when you have to to develop with the MK framework, they're noted here:

## GOTCHA 1 - MK Framework Handler Error #

When you see an error like this:

```Run options: include {:locations=>{"./spec/request/weather_spec.rb"=>[17]}}
ERROR: Roda::RodaError
{
  "request_info": {
    "path": ...
    "method": "GET",
    "params": {
      "id": ...
    },
    "message": "unsupported block result: #<WeatherShowHandler:0x0..., :fetched_at=>2025-05-18 06:37:14.068235 +0200}>>"
  },
  "trace": {
    "relevant": [
      "/Users/makevoid/apps/mk_framework/lib/mk_framework...:in `block (4 levels) in register_resource_routes'",
      ...'",
      "/Users/makevoid/apps/mk_framework/sample_apps/samp...ec.rb:18:in `block (4 levels) in <top (required)>'"
    ]
  }
}
F
```

this means that the handler is not returning the right result in the handler for weather / show - WeatherShowHandler - which you can find in `./routes/weather/handlers/show.rb`

---

## GOTCHA 2 - MK Framework Handler Error #2

This is wrong and you will receive an Handler Error

```
class WeatherIndexHandler < MK::Handler
  handler do |r|
    success do |r|
      ...
    end

    ...
  end
end
```

This is correct, the code will work like this and return the value defined in the handler

```
class WeatherIndexHandler < MK::Handler
  handler do |r|
    ...
  end
end
```

Remember that in Index and Show handlers there is no `model.save` or `model.destroy` - they are handled by the framework internally between controller and handlers.

## GOTCHA 3 - MK Framework Controller and Handlers use blocks, you can't return

MK Framework Controller and Handlers use blocks, you can't return values from them. Instead, you should use the `next` block to pass control to the next handler using ruby blocks syntax.


```
handler do
errors.merge!(user.errors)
next # Stops execution if save fails
```

```
class TodosIndexHandler < MK::Handler
  handler do |r|
    next if model.inactive?
  end
end
```

## Framework Notes

The MK Framework has some unique conventions:

- DELETE operations use POST to `/:resource/:id/delete` instead of DELETE method
- UPDATE operations use POST to `/:resource/:id` instead of PUT/PATCH
- Controllers handle data operations, handlers manage response formatting
