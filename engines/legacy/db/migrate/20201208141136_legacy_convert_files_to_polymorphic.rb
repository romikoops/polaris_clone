class LegacyConvertFilesToPolymorphic < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_foreign_key :legacy_files, column: :user_id

      add_column :legacy_files, :user_type, :string
      add_index :legacy_files, [:user_id, :user_type], algorithm: :concurrently
    end
  end
end
