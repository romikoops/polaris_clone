# frozen_string_literal: true

class AddCheckConstraintForUsersClientToEnforeLowercaseEmail < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_lock_timeout(1000)
  set_statement_timeout(15_000)

  def change
    safety_assured do
      add_check_constraint :users_clients, "email = lower(email)", name: "email_is_lower_case"
    end
  end
end
