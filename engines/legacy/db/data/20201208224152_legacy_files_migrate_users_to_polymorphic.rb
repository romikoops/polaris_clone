class LegacyFilesMigrateUsersToPolymorphic < ActiveRecord::Migration[5.2]
  def up
    Legacy::LegacyFilesMigrateUsersToPolymorphicWorker.perform_async
  end
end
