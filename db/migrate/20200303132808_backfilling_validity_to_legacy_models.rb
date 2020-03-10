# frozen_string_literal: true

class BackfillingValidityToLegacyModels < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      exec_update <<~SQL
        UPDATE pricings
          SET validity = daterange(pricings.effective_date::date, pricings.expiration_date::date)
         WHERE pricings.validity is NULL
      SQL
      exec_update <<~SQL
        UPDATE local_charges
          SET validity = daterange(local_charges.effective_date::date, local_charges.expiration_date::date)
         WHERE local_charges.validity is NULL
      SQL
    end
  end
end
