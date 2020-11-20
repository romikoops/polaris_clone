# frozen_string_literal: true

module Integrations
  module ChainIo
    class ServiceInvoiceLineItem
      def initialize(charge_breakdown:)
        @charge_breakdown = charge_breakdown
      end

      def format
        @charge_breakdown.charges.where(detail_level: 3).map do |charge|
          charge_price = charge.price
          {charge_code: charge.charge_category.code,
           unit_price: charge_price.value.to_d,
           currency: charge_price.currency}
        end
      end
    end
  end
end
