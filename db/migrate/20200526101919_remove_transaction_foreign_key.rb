# frozen_string_literal: true
class RemoveTransactionForeignKey < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :shipments, :transport_category_id, :integer }
  end
end
