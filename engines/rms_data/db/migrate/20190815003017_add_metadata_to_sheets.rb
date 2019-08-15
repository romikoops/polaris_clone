class AddMetadataToSheets < ActiveRecord::Migration[5.2]
  def change
    add_column :rms_data_sheets, :name, :string
    add_column :rms_data_sheets, :metadata, :jsonb, default: {}
  end
end
