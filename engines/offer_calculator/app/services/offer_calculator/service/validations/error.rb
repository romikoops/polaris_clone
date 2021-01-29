# frozen_string_literal: true

module OfferCalculator
  module Service
    module Validations
      class Error < StandardError
        attr_reader :id, :section, :limit, :attribute, :message, :code, :value

        def initialize(id:, section:, attribute:, message:, code:, value: nil, limit: nil)
          @id = id
          @section = section
          @attribute = attribute
          @message = message
          @code = code
          @limit = limit
          @value = value
        end

        def matches?(cargo:, attr:, aggregate: false)
          aggregate_match = (aggregate && id == "aggregate")
          (aggregate_match || id == cargo&.id) && attr == attribute
        end
      end
    end
  end
end
