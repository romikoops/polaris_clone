# frozen_string_literal: true

class AnonymiseComments < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      # Contacts
      change_column :contacts, :first_name, :string, comment: "MASKED WITH FUNCTION anon.random_first_name()"
      change_column :contacts, :last_name, :string, comment: "MASKED WITH FUNCTION anon.random_last_name()"
      change_column :contacts, :phone, :string, comment: "MASKED WITH FUNCTION anon.random_phone()"
      change_column :contacts, :email, :string, comment: "MASKED WITH FUNCTION anon.random_email()"

      # Notes
      change_column :notes, :body, :string, comment: 'MASKED WITH CONSTANT ""'
      change_column :notes, :header, :string, comment: 'MASKED WITH CONSTANT ""'

      # Users
      change_column :users, :first_name, :string, comment: "MASKED WITH FUNCTION anon.random_first_name()"
      change_column :users, :last_name, :string, comment: "MASKED WITH FUNCTION anon.random_last_name()"
      change_column :users, :phone, :string, comment: "MASKED WITH FUNCTION anon.random_phone()"
      change_column :users, :email, :string, comment: "MASKED WITH FUNCTION anon.random_email()"
    end
  end
end
