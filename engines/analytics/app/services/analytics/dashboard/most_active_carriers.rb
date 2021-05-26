# frozen_string_literal: true

module Analytics
  module Dashboard
    class MostActiveCarriers < Analytics::Dashboard::Base
      def data
        @data ||= tally(
          requests: main_freight_sections,
          grouping_attribute: "carrier",
          order_by_count: true,
          order: :desc
        )
      end
    end
  end
end
