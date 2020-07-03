# frozen_string_literal: true

module Analytics
  module Dashboard
    class BookingsPerCompany < Analytics::Dashboard::Base
      def data
        @data ||= tally(
          requests: requests_with_companies,
          grouping_attribute: 'companies_companies.name',
          order_by_count: true,
          order: :desc
        )
      end
    end
  end
end
