# frozen_string_literal: true

module SampleApp5
  class CardsController < Controller
    def dataset(_r) = Card.dataset

    def find(r)
      dataset(r).where(id: r.path_params.fetch(:id)).first or raise MK::NotFound, 'Card not found'
    end
  end
end
