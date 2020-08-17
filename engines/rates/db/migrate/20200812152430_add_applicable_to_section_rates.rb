# frozen_string_literal: true

class AddApplicableToSectionRates < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :rates_sections, :applicable_to, polymorphic: true, type: :uuid, index: {algorithm: :concurrently}
  end
end
