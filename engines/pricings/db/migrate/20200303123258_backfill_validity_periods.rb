# frozen_string_literal: true

class BackfillValidityPeriods < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      exec_update <<~SQL
        UPDATE pricings_pricings
          SET validity = daterange(pricings_pricings.effective_date::date, pricings_pricings.expiration_date::date)
         WHERE pricings_pricings.validity is NULL
      SQL
      exec_update <<~SQL
        UPDATE pricings_margins
          SET validity = daterange(pricings_margins.effective_date::date, pricings_margins.expiration_date::date)
         WHERE pricings_margins.validity is NULL
      SQL
    end
  end
end
