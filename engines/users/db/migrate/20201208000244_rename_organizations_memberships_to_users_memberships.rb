# frozen_string_literal: true
class RenameOrganizationsMembershipsToUsersMemberships < ActiveRecord::Migration[5.2]
  def change
    # Accept downtime deployment
    safety_assured do
      rename_table :organizations_memberships, :users_memberships
    end
  end
end
