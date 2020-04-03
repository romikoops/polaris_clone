# frozen_string_literal: true

module Analytics
  module Dashboard
    class MostActiveCarriers < Analytics::Dashboard::Base
      def data
        @data ||= tally(
          requests: tenders.joins(tenant_vehicle: :carrier),
          grouping_attribute: 'carriers.name',
          order_by_count: true,
          order: :desc
        )
      end
    end
  end
end
