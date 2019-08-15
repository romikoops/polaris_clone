class AddMetadataToBooks < ActiveRecord::Migration[5.2]
  def change
    add_column :rms_data_books, :metadata, :jsonb, default: {}
  end
end
