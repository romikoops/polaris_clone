# frozen_string_literal: true

class AddExternalIdToUserModel < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :external_id, :string
  end
end
