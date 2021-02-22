# frozen_string_literal: true
class CorrectRestraints < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_presence_constraint :journey_line_items, :note
      remove_numericality_constraint :journey_cargo_units, :width_value
      remove_numericality_constraint :journey_cargo_units, :length_value
      remove_numericality_constraint :journey_cargo_units, :height_value

      execute <<-SQL
        ALTER TABLE journey_line_items
          DROP CONSTRAINT journey_line_items_line_item_set_id_route_section_id_route_poin;
      SQL

      add_numericality_constraint :journey_cargo_units, :width_value, greater_than_or_equal_to: 0
      add_numericality_constraint :journey_cargo_units, :length_value, greater_than_or_equal_to: 0
      add_numericality_constraint :journey_cargo_units, :height_value, greater_than_or_equal_to: 0
    end
  end
end
