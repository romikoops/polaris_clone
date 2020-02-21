# frozen_string_literal: true

class DeprecateProfileColumnsFromUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :users, :first_name, :first_name_20200207
      rename_column :users, :last_name, :last_name_20200207
      rename_column :users, :phone, :phone_20200207
      rename_column :users, :company_name, :company_name_20200207
    end
  end
end
