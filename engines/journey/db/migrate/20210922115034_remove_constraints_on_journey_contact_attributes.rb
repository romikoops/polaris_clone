# frozen_string_literal: true

class RemoveConstraintsOnJourneyContactAttributes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      # rubocop:disable Naming/VariableNumber
      change_column_default(:journey_contacts, :address_line_1, nil)
      change_column_null(:journey_contacts, :address_line_1, true)

      change_column_default(:journey_contacts, :address_line_2, nil)
      change_column_null(:journey_contacts, :address_line_2, true)

      change_column_default(:journey_contacts, :address_line_3, nil)
      change_column_null(:journey_contacts, :address_line_3, true)
      # rubocop:enable Naming/VariableNumber

      change_column_default(:journey_contacts, :city, nil)
      change_column_null(:journey_contacts, :city, true)

      change_column_default(:journey_contacts, :company_name, nil)
      change_column_null(:journey_contacts, :company_name, true)

      change_column_null(:journey_contacts, :country_code, true)

      change_column_default(:journey_contacts, :email, nil)
      change_column_null(:journey_contacts, :email, true)

      change_column_null(:journey_contacts, :function, true)

      change_column_null(:journey_contacts, :name, true)

      change_column_default(:journey_contacts, :phone, nil)
      change_column_null(:journey_contacts, :phone, true)

      change_column_null(:journey_contacts, :point, true)

      change_column_default(:journey_contacts, :postal_code, nil)
      change_column_null(:journey_contacts, :postal_code, true)

      change_column_null(:journey_contacts, :original_id, true)
    end
  end
end
