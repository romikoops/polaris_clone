class AddVolumeToJourneyCargoUnits < ActiveRecord::Migration[5.2]
  def up
    add_column :journey_cargo_units, :volume_unit, :string
    change_column_default :journey_cargo_units, :volume_unit, "m3"
    add_column :journey_cargo_units, :volume_value, :decimal
  end

  def down
    remove_column :journey_cargo_units, :volume_unit
    remove_column :journey_cargo_units, :volume_value
  end
end
