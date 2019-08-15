# frozen_string_literal: true

class BackFillSheetsMetadata < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    RmsData::Sheet.in_batches.update_all(metadata: {})
  end
end
