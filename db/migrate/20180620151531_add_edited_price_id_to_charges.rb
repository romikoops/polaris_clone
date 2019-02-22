# frozen_string_literal: true

class AddEditedPriceIdToCharges < ActiveRecord::Migration[5.1]
  def change
    add_column :charges, :edited_price_id, :integer
  end
end
