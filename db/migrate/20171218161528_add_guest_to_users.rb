# frozen_string_literal: true

class AddGuestToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :guest, :boolean, default: false
  end
end
