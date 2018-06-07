# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.string :title
      t.string :message
      t.integer :conversation_id
      t.boolean :read
      t.datetime :read_at
      t.integer :sender_id
      t.timestamps
    end
  end
end
