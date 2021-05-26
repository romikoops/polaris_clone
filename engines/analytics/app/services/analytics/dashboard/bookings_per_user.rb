# frozen_string_literal: true

module Analytics
  module Dashboard
    class BookingsPerUser < Analytics::Dashboard::Base
      TOP_USERS = 10

      def data
        @data ||= requests_with_profiles
          .group("users_client_profiles.id")
          .order("count DESC")
          .limit(TOP_USERS)
          .pluck("CONCAT(users_client_profiles.first_name, ' ', users_client_profiles.last_name), COUNT(*) AS count")
          .map { |label, count| { label: label, count: count } }
      end
    end
  end
end
