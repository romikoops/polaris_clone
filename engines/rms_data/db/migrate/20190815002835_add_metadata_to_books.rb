# frozen_string_literal: true

class AddMetadataToBooks < ActiveRecord::Migration[5.2]
  def up
    add_column :rms_data_books, :metadata, :jsonb
    change_column_default :rms_data_books, :metadata, {}
  end

  def down
    remove_column :rms_data_books, :metadata
  end
end
