# frozen_string_literal: true

class AddMetadataToSheets < ActiveRecord::Migration[5.2]
  def up
    add_column :rms_data_sheets, :name, :string
    add_column :rms_data_sheets, :metadata, :jsonb
    change_column_default :rms_data_sheets, :metadata, {}
  end

  def down
    remove_column :rms_data_sheets, :metadata
  end
end
