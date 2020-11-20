# frozen_string_literal: true

class ChangeProviderFromUsers < ActiveRecord::Migration[5.1]
  def up
    change_column_default :users, :provider, "tenant_email"
  end
end
