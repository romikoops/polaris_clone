# frozen_string_literal: true

class BackfillTenantsUserToQuotations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    exec_update <<~SQL
      UPDATE quotations_quotations
      SET tenants_user_id = tenants_users.id
      FROM tenants_users
      WHERE tenants_users.legacy_id = quotations_quotations.user_id
    SQL
  end
end
