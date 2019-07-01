# frozen_string_literal: true

class AddingSandboxFlagsToPricings < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_pricings, :sandbox_id, :uuid, index: true
    add_column :pricings_margins, :sandbox_id, :uuid, index: true
    add_column :pricings_rate_bases, :sandbox_id, :uuid, index: true
    add_column :pricings_details, :sandbox_id, :uuid, index: true
    add_column :pricings_fees, :sandbox_id, :uuid, index: true
  end
end
