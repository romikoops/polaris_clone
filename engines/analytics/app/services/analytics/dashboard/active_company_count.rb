# frozen_string_literal: true

module Analytics
  module Dashboard
    class ActiveCompanyCount < Analytics::Dashboard::Base
      def data
        @data = clients
          .where(last_login_at: (start_date...end_date))
          .joins(companies_join)
          .select("companies_memberships.company_id")
          .distinct
          .count
      end

      private

      def companies_join
        <<-SQL
          INNER JOIN companies_memberships
            ON companies_memberships.member_id = users_clients.id
            AND companies_memberships.member_type = 'Users::Client'
        SQL
      end
    end
  end
end
