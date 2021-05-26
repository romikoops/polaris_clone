# frozen_string_literal: true

module Analytics
  module Dashboard
    class ModeOfTransportShare < Analytics::Dashboard::Base
      def data
        @data ||= tally(
          requests: main_freight_sections,
          grouping_attribute: "mode_of_transport",
          order_by_count: true,
          order: :desc
        )
      end
    end
  end
end
