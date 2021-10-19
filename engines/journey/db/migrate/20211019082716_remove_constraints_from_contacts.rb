# frozen_string_literal: true

class RemoveConstraintsFromContacts < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute("ALTER TABLE journey_contacts DROP CONSTRAINT journey_contacts_name_presence;")
      execute("ALTER TABLE journey_contacts DROP CONSTRAINT journey_contacts_phone_presence;")
    end
  end

  def down; end
end
