class AddColliTypeToCargoUnits < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE journey_colli_type AS ENUM (
          'barrel',
          'bottle',
          'carton',
          'case',
          'crate',
          'drum',
          'package',
          'pallet',
          'roll',
          'skid',
          'stack');
      SQL
    end

    add_column :journey_cargo_units, :colli_type, :journey_colli_type
  end

  def down
    remove_column :journey_cargo_units, :colli_type, :journey_colli_type

    execute <<-SQL
      DROP TYPE journey_colli_type
    SQL
  end
end
