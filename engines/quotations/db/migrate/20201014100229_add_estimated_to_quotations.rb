# frozen_string_literal: true
class AddEstimatedToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_quotations, :estimated, :boolean
  end
end
