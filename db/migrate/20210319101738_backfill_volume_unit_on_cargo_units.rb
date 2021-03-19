class BackfillVolumeUnitOnCargoUnits < ActiveRecord::Migration[5.2]
  def change
    exec_update("
      UPDATE journey_cargo_units
      SET volume_unit = 'm3'
      WHERE volume_unit IS NULL
    ")
  end
end
