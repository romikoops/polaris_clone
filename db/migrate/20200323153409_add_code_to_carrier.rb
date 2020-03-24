# frozen_string_literal: true

class AddCodeToCarrier < ActiveRecord::Migration[5.2]
  def change
    add_column :carriers, :code, :string, index: true
  end
end
