# frozen_string_literal: true

class AddEmailLinksToTenants < ActiveRecord::Migration[5.1]
  def change
    add_column :tenants, :email_links, :jsonb
  end
end
