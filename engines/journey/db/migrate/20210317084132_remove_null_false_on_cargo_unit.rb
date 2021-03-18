class RemoveNullFalseOnCargoUnit < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      change_column_null :journey_cargo_units, :height_value, true
      change_column_null :journey_cargo_units, :width_value, true
      change_column_null :journey_cargo_units, :length_value, true

      change_column_default :journey_cargo_units, :height_value, nil
      change_column_default :journey_cargo_units, :width_value, nil
      change_column_default :journey_cargo_units, :length_value, nil
    end
  end
end
