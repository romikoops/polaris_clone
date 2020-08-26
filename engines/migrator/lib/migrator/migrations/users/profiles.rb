# frozen_string_literal: true

module Migrator
  module Migrations
    module Users
      class Profiles < Base
        def data
          <<~SQL
            INSERT INTO profiles_profiles (user_id, first_name, last_name, company_name, phone)
            SELECT users_users.id, '', '', '', ''
            FROM users_users
            LEFT JOIN profiles_profiles
            ON users_users.id = profiles_profiles.user_id
            WHERE profiles_profiles.user_id IS NULL
          SQL
        end

        def count_required
          count("SELECT count(*) FROM users_users
                LEFT JOIN profiles_profiles
                ON users_users.id = profiles_profiles.user_id
                WHERE profiles_profiles.user_id IS NULL")
        end
      end
    end
  end
end
