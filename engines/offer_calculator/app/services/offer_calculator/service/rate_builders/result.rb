# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class Result
        attr_accessor :fees, :object, :measures

        def initialize(object:, measures:)
          @fees = []
          @object = object
          @measures = measures
        end
      end
    end
  end
end
