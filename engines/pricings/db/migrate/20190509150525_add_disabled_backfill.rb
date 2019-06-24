# frozen_string_literal: true

class AddDisabledBackfill < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    Pricings::Pricing.in_batches.update_all disabled: false
  end
end
