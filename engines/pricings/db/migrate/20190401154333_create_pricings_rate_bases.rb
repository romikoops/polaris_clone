# frozen_string_literal: true

class CreatePricingsRateBases < ActiveRecord::Migration[5.2]
  def change
    create_table :pricings_rate_bases, id: :uuid do |t|
      t.string :external_code, index: true
      t.string :internal_code
      t.string :description
      t.timestamps
    end
  end
end
