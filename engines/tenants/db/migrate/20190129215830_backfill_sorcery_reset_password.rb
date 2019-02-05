# frozen_string_literal: true

class BackfillSorceryResetPassword < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    Tenants::User.in_batches.update_all(access_count_to_reset_password_page: 0, failed_logins_count: 0)
  end
end
