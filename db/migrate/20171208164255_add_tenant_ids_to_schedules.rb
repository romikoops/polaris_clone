class AddTenantIdsToSchedules < ActiveRecord::Migration[5.1]
  def change
    add_column :schedules, :tenant_id, :integer
  end
end
