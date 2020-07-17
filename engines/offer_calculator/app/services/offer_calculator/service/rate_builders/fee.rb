# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class Fee
        LCL_TRUCKING_CODES = %w[stackable non_stackable].freeze
        attr_reader :charge_category, :code, :name, :min_value, :target, :rate_basis,
          :max_value, :measures
        attr_accessor :components

        delegate :code, to: :charge_category
        delegate :object, :stackability, to: :measures
        delegate :section, :load_type, :cargo_class, :validity, :itinerary_id, :tenant_vehicle_id, to: :object

        def initialize(inputs:)
          @components = []
          @rate_basis = inputs.rate_basis
          @charge_category = inputs.charge_category
          @min_value = inputs.min_value
          @max_value = inputs.max_value
          @target = inputs.target
          @measures = inputs.measures
        end

        def breakdowns
          @breakdowns ||= begin
            code_for_matching = LCL_TRUCKING_CODES.include?(code) ? "trucking_lcl" : code
            object.breakdowns.select { |breakdown| breakdown.code == code_for_matching }
          end
        end

        def pricing_id
          object.id
        end
      end
    end
  end
end
