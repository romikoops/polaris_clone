# frozen_string_literal: true

class AddTenantsUserToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_quotations, :tenants_user_id, :uuid, index: true
  end
end
