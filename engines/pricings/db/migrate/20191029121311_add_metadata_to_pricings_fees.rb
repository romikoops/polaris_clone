# frozen_string_literal: true

class AddMetadataToPricingsFees < ActiveRecord::Migration[5.2]
  def up
    add_column :pricings_fees, :metadata, :jsonb
    change_column_default :pricings_fees, :metadata, {}
  end

  def down
    remove_column :pricings_fees, :metadata
  end
end
