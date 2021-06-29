# frozen_string_literal: true

class AddUniqueConstraintToChargeCategories < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :charge_categories, %i[
      code
      organization_id
    ],
      unique: true,
      algorithm: :concurrently,
      name: "charge_category_upsert",
      where: "cargo_unit_id IS NULL"
  end
end
