# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      FeeInputs = Struct.new(
        :charge_category,
        :rate_basis,
        :min_value,
        :max_value,
        :measures,
        :target,
        keyword_init: true
      )

      class Base
        STANDARD_RATE_BASES = OfferCalculator::Service::RateBuilders::Lookups::STANDARD_RATE_BASES
        NON_STANDARD_RATE_BASIS_MODIFIER_LOOKUP =
          OfferCalculator::Service::RateBuilders::Lookups::NON_STANDARD_RATE_BASIS_MODIFIER_LOOKUP
        SHIPMENT_LEVEL_RATE_BASES = OfferCalculator::Service::RateBuilders::Lookups::SHIPMENT_LEVEL_RATE_BASES
        MODIFIERS_BY_RATE_BASIS = OfferCalculator::Service::RateBuilders::Lookups::MODIFIERS_BY_RATE_BASIS
        DEFAULT_MAX = 1e12

        def self.fees(quotation:, measures:)
          new(quotation: quotation, measures: measures).perform
        end

        def initialize(quotation:, measures:)
          @quotation = quotation
          @measures = measures
          @fees = []
        end

        def perform
          measures.children.each do |target_measure|
            @fees |= handle_json_fees(json: object.fees, target_measure: target_measure)
          end
          @fees
        rescue
          raise OfferCalculator::Errors::RateBuilderError
        end

        private

        attr_reader :measures, :quotation

        def object
          @object ||= measures.object
        end

        def determine_target(rate_basis:, target_measure: measures)
          SHIPMENT_LEVEL_RATE_BASES.include?(rate_basis) ? parent_cargo : target_measure.cargo
        end

        def parent_cargo
          measures.cargo.is_a?(Cargo::Unit) ? measures.cargo.cargo : measures.cargo
        end

        def handle_json_fees(json:, target_measure:)
          json.map do |key, raw_fee|
            OfferCalculator::Service::RateBuilders::FeeBuilder.fee(
              quotation: quotation, fee: raw_fee, measures: target_measure, code: key
            ).tap do |fee|
              fee.components = OfferCalculator::Service::RateBuilders::FeeComponentBuilder.components(
                fee: raw_fee, measures: target_measure
              )
            end
          end
        end
      end
    end
  end
end
