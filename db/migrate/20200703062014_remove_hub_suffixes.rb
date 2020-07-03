class RemoveHubSuffixes < ActiveRecord::Migration[5.2]
  def change
    exec_update <<-SQL
      UPDATE hubs
      SET name = nexuses.name
      FROM nexuses
      WHERE nexuses.id = hubs.nexus_id
    SQL
  end
end
