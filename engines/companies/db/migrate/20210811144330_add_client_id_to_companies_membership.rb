# frozen_string_literal: true

class AddClientIdToCompaniesMembership < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    safety_assured do
      change_table :companies_memberships do |cm|
        cm.references :client, type: :uuid,
                               foreign_key: { to_table: "users_clients", on_delete: :cascade },
                               index: { unique: true,
                                        where: "deleted_at is null",
                                        algorithm: :concurrently,
                                        name: "companies_memberships_client_id" },
                               dependent: :destroy
      end
    end
  end
end
