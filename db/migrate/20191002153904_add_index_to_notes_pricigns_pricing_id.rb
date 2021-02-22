# frozen_string_literal: true
class AddIndexToNotesPricignsPricingId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :notes, :pricings_pricing_id, algorithm: :concurrently
  end
end
