# frozen_string_literal: true

class CreateSequentialSequences < ActiveRecord::Migration[5.2]
  def up
    create_table :sequential_sequences, id: :uuid do |t|
      t.bigint :value, default: 0
      t.integer :name
      t.timestamps
    end
  end

  def down
    drop_table :sequential_sequences
  end
end
