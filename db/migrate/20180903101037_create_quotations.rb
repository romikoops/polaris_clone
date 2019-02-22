# frozen_string_literal: true

class CreateQuotations < ActiveRecord::Migration[5.2]
  def change
    create_table :quotations do |t|
      t.string :target_email
      t.integer :user_id
      t.string :name
      t.timestamps
    end
  end
end
