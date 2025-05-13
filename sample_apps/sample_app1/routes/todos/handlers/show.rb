# frozen_string_literal: true

class TodosShowHandler < MK::Handler
  route do |r|
    if model.nil?
      r.response.status = 404
      { error: "Todo not found" }
    else
      # Return the todo as a hash - Roda can handle this with the json plugin
      model.to_hash
    end
  end
end
