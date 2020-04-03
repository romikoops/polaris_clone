# frozen_string_literal: true

module Analytics
  module Dashboard
    class ActiveClientCount < Analytics::Dashboard::Base
      def data
        @data ||= legacy_clients
                  .where(last_sign_in_at: (start_date...end_date))
                  .count
      end
    end
  end
end
