# frozen_string_literal: true

module SampleApp2
  class TodosController < Controller
    def dataset(_r) = Todo.dataset

    def find(r)
      dataset(r).where(id: r.path_params.fetch(:id)).first or raise MK::NotFound, 'Todo not found'
    end
  end
end
