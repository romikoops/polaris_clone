# frozen_string_literal: true

class CreateCmsDataWidgets < ActiveRecord::Migration[5.2]
  def change
    create_table :cms_data_widgets, id: :uuid do |t|
      t.string :name, null: false
      t.integer :order, null: false
      t.string :data, null: false
      t.references :organization, index: true, foreign_key: {to_table: :organizations_organizations}, type: :uuid

      t.timestamps
    end
  end
end
