# frozen_string_literal: true

module Integrations
  module ChainIo
    class ServiceInvoice
      def initialize(charge_breakdown:)
        @charge_breakdown = charge_breakdown
      end

      def format
        grand_total_price = @charge_breakdown.grand_total.price
        {
          currency: grand_total_price.currency,
          service_invoice_line: service_invoice_line_items,
          total_due: grand_total_price.value.to_d
        }
      end

      def service_invoice_line_items
        Integrations::ChainIo::ServiceInvoiceLineItem.new(charge_breakdown: @charge_breakdown).format
      end
    end
  end
end
