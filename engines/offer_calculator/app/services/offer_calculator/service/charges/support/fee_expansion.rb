# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module Support
        class FeeExpansion
          attr_reader :fees, :base

          def initialize(fees:, base:)
            @fees = fees
            @base = base
          end

          def perform
            fees.flat_map do |key, fee_row|
              OfferCalculator::Service::Charges::Support::ExpandedFee.new(fee: fee_row.merge("code" => key.downcase), base: base).perform
            end
          end
        end
      end
    end
  end
end
