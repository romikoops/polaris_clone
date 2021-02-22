# frozen_string_literal: true
class AddConstraintsToCarriers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :carriers, :code, unique: true, algorithm: :concurrently, where: "deleted_at is null"
  end
end
