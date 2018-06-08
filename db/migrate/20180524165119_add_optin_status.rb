# frozen_string_literal: true

class AddOptinStatus < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :optin_status_id, :integer
  end
end
