class ConvertJourneyQueryCreatorPolymorphic < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_index :journey_queries, :creator_id

      add_column :journey_queries, :creator_type, :string
      add_index :journey_queries, [:creator_id, :creator_type], algorithm: :concurrently
    end
  end
end
