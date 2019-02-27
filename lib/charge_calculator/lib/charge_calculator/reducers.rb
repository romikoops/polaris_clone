# frozen_string_literal: true

module ChargeCalculator
  module Reducers
    NoSuchReducerError = Class.new(StandardError)

    REDUCERS = {
      max: Max,
      sum: Sum,
      first: First
    }.freeze

    def self.get(key)
      raise NoSuchReducerError, "The Reducer '#{key}' doesn't exist" unless REDUCERS.has_key? key

      REDUCERS[key].new
    end
  end
end
