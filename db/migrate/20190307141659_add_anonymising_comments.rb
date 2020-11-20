# frozen_string_literal: true

class AddAnonymisingComments < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      # Contacts
      change_column_comment :contacts, :first_name, "MASKED WITH FirstName"
      change_column_comment :contacts, :last_name, "MASKED WITH LastName"
      change_column_comment :contacts, :phone, "MASKED WITH Phone"
      change_column_comment :contacts, :email, "MASKED WITH EmailAddress"

      # Notes
      change_column_comment :notes, :body, "MASKED WITH literal:"
      change_column_comment :notes, :header, "MASKED WITH literal:"

      # Users
      change_table_comment :users,
        "FILTER WITH users.email NOT LIKE '%@itsmycargo.com' AND users.email NOT LIKE '%demo%@%'"
      change_column_comment :users, :first_name, "MASKED WITH FirstName"
      change_column_comment :users, :last_name, "MASKED WITH LastName"
      change_column_comment :users, :phone, "MASKED WITH Phone"
      change_column_comment :users, :email, "MASKED WITH EmailAddress"

      # Versions
      change_table_comment :versions, "IGNORE DATA"
    end
  end
end
