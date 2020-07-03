# frozen_string_literal: true

module Analytics
  module Dashboard
    class ActiveCompanyCount < Analytics::Dashboard::Base
      def data
        @data = clients
                .where(last_login_at: (start_date...end_date))
                .joins(companies_join)
                .select('companies_memberships.company_id')
                .distinct
                .count
      end

      private

      def companies_join
        # Polymorphic association with member doesn't allow the type get set correctly
        # so Organizations::User will be stored as member_type: Users::User.
        <<-SQL
          INNER JOIN companies_memberships
            ON companies_memberships.member_id = users_users.id
            AND companies_memberships.member_type = 'Users::User'
        SQL
      end
    end
  end
end
