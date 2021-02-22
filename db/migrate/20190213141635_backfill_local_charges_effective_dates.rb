# frozen_string_literal: true
class BackfillLocalChargesEffectiveDates < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    LocalCharge.where(effective_date: nil).update_all(effective_date: Date.parse("01 Jan 2019"))
    LocalCharge.where(expiration_date: nil).update_all(expiration_date: Date.parse("01 Jul 2019"))
  end
end
