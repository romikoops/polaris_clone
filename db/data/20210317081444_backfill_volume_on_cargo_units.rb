class BackfillVolumeOnCargoUnits < ActiveRecord::Migration[5.2]
  def up
    exec_update("
      UPDATE journey_cargo_units
      SET volume_value = width_value * length_value * height_value
      WHERE cargo_class IN ('lcl', 'aggregated_lcl')
    ")
    exec_update("
      UPDATE journey_cargo_units
      SET width_value = NULL, length_value = NULL , height_value = NULL
      WHERE cargo_class NOT IN ('lcl')
    ")
    exec_update("
      UPDATE journey_cargo_units
      SET volume_value = NULL
      WHERE cargo_class NOT IN ('lcl', 'aggregated_lcl')
    ")
  end
end
