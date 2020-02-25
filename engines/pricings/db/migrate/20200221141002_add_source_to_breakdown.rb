# frozen_string_literal: true

class AddSourceToBreakdown < ActiveRecord::Migration[5.2]
  def change
    add_reference :pricings_breakdowns, :source, polymorphic: true, index: false, type: :uuid
  end
end
