# frozen_string_literal: true

class CreateAlternativeNames < ActiveRecord::Migration[5.1]
  def change
    create_table :alternative_names do |t|
      t.string :model
      t.string :model_id
      t.string :name
      t.string :locale
      t.timestamps
    end
  end
end
