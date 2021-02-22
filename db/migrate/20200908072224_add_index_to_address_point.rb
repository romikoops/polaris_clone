# frozen_string_literal: true
class AddIndexToAddressPoint < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :addresses, :point, using: :gist, algorithm: :concurrently
  end
end
