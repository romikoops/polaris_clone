# frozen_string_literal: true
class ChangeCreatorReferenceOnQuotationsQuotations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_foreign_key :quotations_quotations, column: :creator_id

      add_column :quotations_quotations, :creator_type, :string
      add_index :quotations_quotations, [:creator_id, :creator_type], algorithm: :concurrently
    end
  end
end
