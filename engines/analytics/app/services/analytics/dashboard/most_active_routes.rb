# frozen_string_literal: true

module Analytics
  module Dashboard
    class MostActiveRoutes < Analytics::Dashboard::Base
      TOP_ROUTES = 10

      def data
        @data ||= tally(
          requests: main_freight_sections_with_route_points,
          grouping_attribute: "CONCAT(from_points.name, ' - ', to_points.name)",
          order_by_count: true,
          order: :desc,
          limit: TOP_ROUTES
        )
      end
    end
  end
end
