# frozen_string_literal: true

module Analytics
  module Dashboard
    class AverageBookingValue < Analytics::Dashboard::Base
      def data
        @data ||= (tenders.sum(&:amount) / tenders.length).yield_self do |money|
          {
            symbol: money.currency.iso_code,
            value: money.amount
          }
        end
      end
    end
  end
end
