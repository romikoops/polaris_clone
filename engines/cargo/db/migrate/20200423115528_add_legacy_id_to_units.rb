# frozen_string_literal: true

class AddLegacyIdToUnits < ActiveRecord::Migration[5.2]
  def change
    add_reference :cargo_units, :legacy, polymorphic: true, index: false, type: :integer
  end
end
