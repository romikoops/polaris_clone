# frozen_string_literal: true

class AddingTenantIdToNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :notes, :tenant_id, :integer, index: true
    add_column :notes, :contains_html, :boolean
  end
end
