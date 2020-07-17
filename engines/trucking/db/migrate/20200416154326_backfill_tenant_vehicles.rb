# frozen_string_literal: true

class BackfillTenantVehicles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    Organizations::Organization.find_each do |organization|
      TruckingMigrationJob.perform_later(organization_id: organization.id)
    end
  end

  def down
  end
end
