# frozen_string_literal: true

class Backfillmetadata < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    RmsData::Book.in_batches.update_all(metadata: {})
  end
end
