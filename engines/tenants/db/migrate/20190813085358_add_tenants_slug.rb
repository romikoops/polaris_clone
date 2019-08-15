# frozen_string_literal: true

class AddTenantsSlug < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_tenants, :slug, :string

    # Back fill slug
    safety_assured { execute 'UPDATE tenants_tenants SET slug = subdomain' }
  end
end
