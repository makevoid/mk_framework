# frozen_string_literal: true

class TodosShowHandler < MK::Handler
  route do |r|
    if model.nil?
      r.response.status = 404
      { error: "Todo not found" }
    else
      model
    end
  end
end
