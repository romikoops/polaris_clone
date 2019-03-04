# frozen_string_literal: true

class AddLocodeToName < ActiveRecord::Migration[5.2]
  def change
    add_column :locations_names, :locode, :string
  end
end
