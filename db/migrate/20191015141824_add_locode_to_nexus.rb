# frozen_string_literal: true

class AddLocodeToNexus < ActiveRecord::Migration[5.2]
  def change
    add_column :nexuses, :locode, :string, index: true
  end
end
