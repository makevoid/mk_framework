
#### Delete

```ruby
# routes/todos/controllers/delete.rb
class TodosDeleteController < MK::Controller
  route do |r|
    todo = Todo[r.params.fetch('id')]
    
    r.halt(404, { message: "todo not found" }) if todo.nil?
    
    todo
  end
end
```

```ruby
# routes/todos/handlers/delete.rb
class TodosDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Todo deleted successfully",
        todo: model.to_hash
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete todo"
      }
    end
  end
end
```

TODO: add other cases such as Index which are not yet documented

Reminder on REST MVC CRUD methods:

Show
Index
Create
Update
Delete
