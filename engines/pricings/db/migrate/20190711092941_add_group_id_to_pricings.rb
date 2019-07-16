# frozen_string_literal: true

class AddGroupIdToPricings < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_pricings, :group_id, :uuid, index: true
  end
end
