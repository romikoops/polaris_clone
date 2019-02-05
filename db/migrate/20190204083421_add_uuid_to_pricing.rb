# frozen_string_literal: true

class AddUuidToPricing < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings, :uuid, :uuid
    change_column_default :pricings, :uuid, from: nil, to: 'gen_random_uuid()'
  end
end
