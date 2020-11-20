# frozen_string_literal: true

module Analytics
  module Dashboard
    class MostActiveRoutes < Analytics::Dashboard::Base
      TOP_ROUTES = 10

      def data
        @data ||= tally(
          requests: tender_or_request_with_itinerary,
          grouping_attribute: "itineraries.name",
          order_by_count: true,
          order: :desc,
          limit: TOP_ROUTES
        )
      end
    end
  end
end
