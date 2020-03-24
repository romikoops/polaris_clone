# frozen_string_literal: true

class AddTransshipmentToTender < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_tenders, :transshipment, :string
  end
end
