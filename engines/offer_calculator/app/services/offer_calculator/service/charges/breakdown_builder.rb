# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class BreakdownBuilder
        attr_reader :fee, :metadata

        def initialize(fee:, metadata:)
          @fee = fee
          @metadata = metadata
        end

        def perform
          fees_in_order.map.with_index do |fee, index|
            OfferCalculator::Service::Charges::Breakdown.new(
              order: index,
              fee: fee,
              metadata: metadata
            )
          end
        end

        private

        def fees_in_order
          @fees_in_order ||= parent_fees(fee: fee).reverse
        end

        def parent_fees(fee:)
          return [] if fee.nil?

          [fee, parent_fees(fee: fee.parent)].flatten
        end
      end
    end
  end
end
