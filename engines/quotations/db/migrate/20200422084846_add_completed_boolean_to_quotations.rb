# frozen_string_literal: true

class AddCompletedBooleanToQuotations < ActiveRecord::Migration[5.2]
  def up
    add_column :quotations_quotations, :completed, :boolean, index: true
    change_column_default :quotations_quotations, :completed, false
  end

  def down
    remove_column :quotations_quotations, :completed
  end
end
