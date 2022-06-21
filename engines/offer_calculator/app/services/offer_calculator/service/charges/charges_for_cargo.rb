# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class ChargesForCargo
        def initialize(request:, fee_rows:, margins:)
          @request = request
          @fee_rows = fee_rows
          @margins = margins
          @organization = Organizations::Organization.find(Organizations.current_id)
        end

        def perform
          measures.targets.map do |measured_cargo|
            OfferCalculator::Service::Charges::ChargeBuilder.new(
              fee_rows: fee_rows,
              margin_rows: margins,
              measured_cargo: measured_cargo
            ).perform
          end
        end

        private

        attr_reader :request, :fee_rows, :organization, :margins

        def measures
          @measures ||= OfferCalculator::Service::Measurements::Request.new(
            request: request, object: context, scope: request.scope
          )
        end

        def fee_row
          @fee_row ||= (fee_rows.empty? ? margins : fee_rows).to_a.first
        end

        def context
          @context ||= OfferCalculator::Service::Charges::Context.new(**fee_row.slice(*OfferCalculator::Service::Charges::RelationData::FRAME_KEYS).symbolize_keys)
        end
      end
    end
  end
end
