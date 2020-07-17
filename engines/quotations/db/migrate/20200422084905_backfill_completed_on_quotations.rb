# frozen_string_literal: true

class BackfillCompletedOnQuotations < ActiveRecord::Migration[5.2]
  def up
    exec_update <<~SQL
      UPDATE quotations_quotations
      SET completed = true
      WHERE completed = NULL
    SQL
  end

  def down
  end
end
