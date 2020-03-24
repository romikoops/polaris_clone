# frozen_string_literal: true

class BackfillCarrierCodes < ActiveRecord::Migration[5.2]
  def up
    exec_update <<~SQL
      UPDATE carriers
      SET code = LOWER(carriers.name)
    SQL
  end

  def down
    Legacy::Carrier.where.not(code: nil).update(code: nil)
  end
end
