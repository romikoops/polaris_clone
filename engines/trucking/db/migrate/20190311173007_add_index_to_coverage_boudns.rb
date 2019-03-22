# frozen_string_literal: true

class AddIndexToCoverageBoudns < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :trucking_coverages, :bounds, using: :gist, algorithm: :concurrently
  end
end
