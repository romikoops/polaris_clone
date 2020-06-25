class AddDeletedAtToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles_profiles, :deleted_at, :datetime, index: {algorithm: :concurrently}
  end
end
