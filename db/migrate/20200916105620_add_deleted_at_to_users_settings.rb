# frozen_string_literal: true

class AddDeletedAtToUsersSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :users_settings, :deleted_at, :datetime
  end
end
