# frozen_string_literal: true

class RenameModels < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      remove_column :cargo_groups, :load_id, :uuid
      remove_column :cargo_loads, :weight, :decimal
      remove_column :cargo_loads, :volume, :decimal
      remove_column :cargo_loads, :cargo_class, :bigint
      remove_column :cargo_loads, :cargo_type, :bigint
      remove_column :cargo_loads, :quantity, :integer
      remove_column :cargo_loads, :user_id
      remove_column :cargo_groups, :weight
      remove_column :cargo_groups, :width
      remove_column :cargo_groups, :length
      remove_column :cargo_groups, :height
      remove_column :cargo_groups, :user_id

      rename_table :cargo_groups, :cargo_units
      rename_table :cargo_loads, :cargo_cargos

      add_column :cargo_units, :weight_value, :decimal, default: 0.0, precision: 100, scale: 3
      add_column :cargo_units, :width_value, :decimal, default: 0.0, precision: 100, scale: 4
      add_column :cargo_units, :length_value, :decimal, default: 0.0, precision: 100, scale: 4
      add_column :cargo_units, :height_value, :decimal, default: 0.0, precision: 100, scale: 4
      add_column :cargo_units, :volume_value, :decimal, default: 0.0, precision: 100, scale: 6
      add_column :cargo_units, :volume_unit, :string, default: 'm3'
      add_column :cargo_units, :weight_unit, :string, default: 'kg'
      add_column :cargo_units, :width_unit, :string, default: 'm'
      add_column :cargo_units, :length_unit, :string, default: 'm'
      add_column :cargo_units, :height_unit, :string, default: 'm'

      add_reference :cargo_units, :cargo, foreign_key: { to_table: :cargo_cargos },
                                          type: :uuid, index: true
    end
  end

  def down
    safety_assured do
      remove_column :cargo_units, :cargo_id, :uuid
      remove_column :cargo_units, :volume_unit, :string, default: 'm3'
      remove_column :cargo_units, :weight_unit, :string, default: 'kg'
      remove_column :cargo_units, :width_unit, :string, default: 'm'
      remove_column :cargo_units, :length_unit, :string, default: 'm'
      remove_column :cargo_units, :height_unit, :string, default: 'm'
      remove_column :cargo_units, :volume_value, :decimal, default: 0.0
      remove_column :cargo_units, :weight_value, :decimal, default: 0.0, scale: 5
      remove_column :cargo_units, :width_value, :decimal, default: 0.0, scale: 5
      remove_column :cargo_units, :length_value, :decimal, default: 0.0, scale: 5
      remove_column :cargo_units, :height_value, :decimal, default: 0.0, scale: 5

      rename_table :cargo_units, :cargo_groups
      rename_table :cargo_cargos, :cargo_loads

      add_column :cargo_groups, :weight, :decimal, default: 0.0
      add_column :cargo_groups, :width, :decimal, default: 0.0
      add_column :cargo_groups, :length, :decimal, default: 0.0
      add_column :cargo_groups, :height, :decimal, default: 0.0
      add_column :cargo_groups, :user_id, :uuid, index: true
      add_column :cargo_loads, :weight, :decimal, default: 0.0
      add_column :cargo_loads, :volume, :decimal, default: 0.0
      add_column :cargo_loads, :cargo_class, :bigint, default: 0, index: true
      add_column :cargo_loads, :cargo_type, :bigint, default: 0, index: true
      add_column :cargo_loads, :user_id, :uuid, index: true
      add_column :cargo_loads, :quantity, :integer
      add_column :cargo_groups, :load_id, :uuid
    end
  end
end
