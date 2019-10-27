# frozen_string_literal: true

class AddCompanyNumberToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :company_number, :string
  end
end
