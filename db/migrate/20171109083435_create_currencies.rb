# frozen_string_literal: true

class CreateCurrencies < ActiveRecord::Migration[5.1]
  def change
    create_table :currencies do |t|
      t.jsonb :today
      t.jsonb :yesterday
      t.string :base
      t.timestamps
    end
  end
end
