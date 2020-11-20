# frozen_string_literal: true

class AddPolymorphismToNotes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :notes, :target, polymorphic: true, index: {algorithm: :concurrently}, type: :integer
    end
  end
end
