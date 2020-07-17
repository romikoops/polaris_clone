# frozen_string_literal: true

module OfferCalculator
  module Service
    module Calculators
      class Result
        attr_reader :object, :measures
        attr_accessor :charges

        delegate :validity, :section, :tenant_vehicle_id, :itinerary_id, to: :object
        delegate :cargo_class, :load_type, to: :measures

        def initialize(object:, measures:)
          @object = object
          @measures = measures
          @charges = []
        end

        def total
          charges.sum(&:value)
        end
      end
    end
  end
end
