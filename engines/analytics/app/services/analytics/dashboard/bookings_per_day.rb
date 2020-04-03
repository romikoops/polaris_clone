# frozen_string_literal: true

module Analytics
  module Dashboard
    class BookingsPerDay < Analytics::Dashboard::Base
      def data
        @data ||= tally(
          requests: requests,
          grouping_attribute: "DATE_TRUNC('day', created_at)::date",
          order_by_count: false,
          order: :asc
        )
      end
    end
  end
end
