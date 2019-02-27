# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :tag_type
      t.string :name
      t.string :model
      t.string :model_id
      t.timestamps
    end
  end
end
