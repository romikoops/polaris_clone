# frozen_string_literal: true

module Analytics
  module Dashboard
    class ActiveCompanyCount < Analytics::Dashboard::Base
      def data
        @data ||= clients
                  .joins(:legacy)
                  .merge(legacy_clients)
                  .where(users: { last_sign_in_at: (start_date...end_date) })
                  .select(:company_id)
                  .distinct
                  .count
      end
    end
  end
end
