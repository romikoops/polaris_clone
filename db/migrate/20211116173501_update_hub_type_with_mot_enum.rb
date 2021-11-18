# frozen_string_literal: true

class UpdateHubTypeWithMotEnum < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_statement_timeout(3000)

  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE hub_type_mode_of_transport AS ENUM ('ocean', 'air', 'rail', 'truck');
        ALTER TABLE hubs
        ALTER COLUMN hub_type TYPE hub_type_mode_of_transport
        USING hub_type::hub_type_mode_of_transport;
      SQL
    end
  end

  def down
    safety_assured do
      change_column :hubs, :hub_type, :varchar
      execute <<-SQL
        DROP TYPE hub_type_mode_of_transport;
        ALTER TABLE hubs
        ALTER COLUMN hub_type TYPE varchar;
      SQL
    end
  end
end
