# frozen_string_literal: true

class AddCargoToLineItem < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :quotations_line_items, :cargo, polymorphic: true, index: { algorithm: :concurrently }, type: :integer
    end
  end
end
