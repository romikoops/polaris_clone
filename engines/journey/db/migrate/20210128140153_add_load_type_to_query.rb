class AddLoadTypeToQuery < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE journey_load_type AS ENUM (
          'lcl',
          'fcl');
      SQL
    end

    add_column :journey_queries, :load_type, :journey_load_type
  end

  def down
    remove_column :journey_queries, :load_type, :journey_load_type

    execute <<-SQL
      DROP TYPE journey_load_type
    SQL
  end
end
