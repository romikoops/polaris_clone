# frozen_string_literal: true

class RemovePresenceConstraintsFromContact < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute("ALTER TABLE journey_contacts DROP CONSTRAINT journey_contacts_city_presence;")
      execute("ALTER TABLE journey_contacts DROP CONSTRAINT journey_contacts_company_name_presence;")
      execute("ALTER TABLE journey_contacts DROP CONSTRAINT journey_contacts_country_code_length;")
      execute("ALTER TABLE journey_contacts DROP CONSTRAINT journey_contacts_country_code_presence;")
    end
  end

  def down; end
end
