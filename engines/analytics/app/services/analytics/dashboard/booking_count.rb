# frozen_string_literal: true

module Analytics
  module Dashboard
    class BookingCount < Analytics::Dashboard::Base
      def data
        @data ||= requests.count
      end
    end
  end
end
