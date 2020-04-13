# frozen_string_literal: true

module Analytics
  module Dashboard
    class AverageBookingValue < Analytics::Dashboard::Base
      def data
        @data ||= average_tender_value
      end

      private

      def average_tender_value
        tender_count = tenders.length
        return if tender_count.zero?

        money = tenders.sum(&:amount) / tender_count
        {
          symbol: money.currency.iso_code,
          value: money.amount
        }
      end
    end
  end
end
