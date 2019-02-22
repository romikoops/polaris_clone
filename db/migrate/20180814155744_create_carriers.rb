# frozen_string_literal: true

class CreateCarriers < ActiveRecord::Migration[5.1]
  def change
    create_table :carriers do |t|
      t.string :name
      t.timestamps
    end
  end
end
