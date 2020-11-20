# frozen_string_literal: true

module Analytics
  module Dashboard
    class ModeOfTransportShare < Analytics::Dashboard::Base
      def data
        @data ||= tally(
          requests: tenders.joins(:itinerary),
          grouping_attribute: "itineraries.mode_of_transport",
          order_by_count: true,
          order: :desc
        )
      end
    end
  end
end
