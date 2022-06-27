# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class Metadatum
        def self.metadatum(offer:, result:)
          new(
            offer: offer, result: result
          ).perform
        end

        def initialize(offer:, result:)
          @offer = offer
          @result = result
        end

        def perform
          offer.charges.each do |charge|
            build_breakdowns_for_charge(charge: charge)
          end
          metadatum
        end

        private

        attr_reader :result, :offer

        def metadatum
          @metadatum ||= Pricings::Metadatum.create(
            organization_id: Organizations.current_id,
            result_id: result.id
          )
        end

        def build_breakdowns_for_charge(charge:)
          records = if charge.is_a?(OfferCalculator::Service::Charges::DecoratedCharge)
            charge.breakdowns
          else
            charge.fee.breakdowns
          end
          records.map.with_index do |result_breakdown, i|
            build_breakdown(
              result_breakdown: result_breakdown,
              charge: charge,
              index: i
            )
          end
        end

        def build_breakdown(result_breakdown:, charge:, index:)
          Pricings::Breakdown.create(
            metadatum: metadatum,
            line_item_id: charge.line_item.id,
            order: index,
            data: result_breakdown.data,
            charge_category_id: result_breakdown.charge_category.id,
            rate_origin: result_breakdown.metadata,
            cargo_class: charge&.cargo_class,
            source: result_breakdown.source,
            target: result_breakdown.source&.applicable
          )
        end

        def current_line_item_set
          @current_line_item_set ||= result.line_item_sets.order(created_at: :desc).first
        end

        delegate :line_items, to: :current_line_item_set
      end
    end
  end
end
