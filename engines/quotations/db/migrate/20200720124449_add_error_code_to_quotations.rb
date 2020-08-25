# frozen_string_literal: true

class AddErrorCodeToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_quotations, :error_class, :string
  end
end
