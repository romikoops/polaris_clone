# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class Fee
        LCL_TRUCKING_CODES = %w[stackable non_stackable].freeze
        FCL_WM_RATE = 0.0001
        attr_reader :charge_category, :code, :name, :min_value, :targets, :rate_basis,
          :max_value, :measures
        attr_accessor :components

        delegate :code, to: :charge_category
        delegate :object, :stackability, :quantity, to: :measures
        delegate :section, :load_type, :cargo_class, :validity, :itinerary_id,
          :tenant_vehicle_id, :truck_type, :hub_id, to: :object

        def initialize(inputs:)
          @components = []
          @rate_basis = inputs.rate_basis
          @charge_category = inputs.charge_category
          @min_value = inputs.min_value
          @max_value = inputs.max_value
          @targets = inputs.targets
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

        def filter_id
          itinerary_id || hub_id
        end

        def flat_margin
          margin_value = (object.flat_margins.dig(code) || 0) * 100
          Money.new(margin_value, max_value.currency)
        end

        def wm_rate
          return FCL_WM_RATE if /fcl/.match?(cargo_class)

          @measures.chargeable_weight_in_tons.value / @measures.volume.value
        end
      end
    end
  end
end
