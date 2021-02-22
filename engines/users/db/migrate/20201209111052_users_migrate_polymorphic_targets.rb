# frozen_string_literal: true
class UsersMigratePolymorphicTargets < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute(<<-SQL)
        UPDATE companies_memberships
          SET member_type = 'Users::Client'
          WHERE member_type = 'Users::User'
      SQL

      execute(<<-SQL)
        UPDATE groups_memberships
          SET member_type = 'Users::Client'
          WHERE member_type = 'Users::User'
      SQL

      execute(<<-SQL)
        UPDATE organizations_scopes
          SET target_type = 'Users::Client'
          WHERE target_type = 'Organizations::User'
      SQL
    end
  end
end
