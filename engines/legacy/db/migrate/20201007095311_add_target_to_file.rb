class AddTargetToFile < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :legacy_files, :target, polymorphic: true, type: :uuid, index: {algorithm: :concurrently}
  end
end
