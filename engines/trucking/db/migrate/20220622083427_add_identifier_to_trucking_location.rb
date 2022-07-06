# frozen_string_literal: true

class AddIdentifierToTruckingLocation < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL.squish
        CREATE TYPE trucking_identifier AS ENUM ('postal_code', 'locode', 'city', 'distance', 'postal_city');
      SQL
    end
    add_column :trucking_locations, :identifier, :trucking_identifier
  end

  def down
    remove_column :trucking_locations, :identifier

    safety_assured do
      execute <<-SQL.squish
        DROP TYPE trucking_identifier;
      SQL
    end
  end
end
