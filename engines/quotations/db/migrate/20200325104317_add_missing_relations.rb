# frozen_string_literal: true

class AddMissingRelations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_quotations, :pickup_address_id, :integer
    add_column :quotations_quotations, :delivery_address_id, :integer
  end
end
