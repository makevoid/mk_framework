# frozen_string_literal: true

module SampleApp6
  class Weather < Sequel::Model(DB[:weathers])
    plugin :validation_helpers

    def validate
      super
      validates_presence [:location, :data, :fetched_at]
      validates_max_length 100, :location
    end
  end
end
