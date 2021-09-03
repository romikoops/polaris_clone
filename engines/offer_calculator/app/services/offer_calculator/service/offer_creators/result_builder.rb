# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class ResultBuilder
        attr_reader :request, :offer

        def self.result(request:, offer:)
          new(request: request, offer: offer).result
        end

        def initialize(request:, offer:)
          @request = request
          @offer = offer
        end

        def result
          ActiveRecord::Base.transaction do
            Journey::Result.create!(
              line_item_sets: [line_item_set],
              route_sections: route_sections,
              result_set: result_set,
              query_id: result_set.query_id,
              issued_at: Time.zone.now,
              expiration_date: offer.valid_until
            ).tap do |new_result|
              Metadatum.metadatum(offer: offer, result: new_result)
            end
          end
        rescue ActiveRecord::RecordInvalid
          raise OfferCalculator::Errors::OfferBuilder
        end

        private

        delegate :query, :result_set, to: :request

        def route_sections
          @route_sections ||= RouteSectionBuilder.route_sections(offer: offer, request: request)
        end

        def line_item_set
          @line_item_set ||= LineItemSetBuilder.line_item_set(offer: offer, request: request, route_sections: route_sections)
        end
      end
    end
  end
end
