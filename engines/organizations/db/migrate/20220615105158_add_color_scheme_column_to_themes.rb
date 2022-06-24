# frozen_string_literal: true

class AddColorSchemeColumnToThemes < ActiveRecord::Migration[5.2]
  def up
    add_column :organizations_themes, :color_scheme, :jsonb
    change_column_default :organizations_themes, :color_scheme, Organizations::DEFAULT_COLOR_SCHEMA
  end

  def down
    remove_column :organizations_themes, :color_scheme
  end
end
