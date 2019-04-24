# frozen_string_literal: true

class AddCompanyIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_users, :company_id, :uuid
  end
end
