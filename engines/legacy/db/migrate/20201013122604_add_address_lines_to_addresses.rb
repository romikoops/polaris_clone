# frozen_string_literal: true
class AddAddressLinesToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :address_line_1, :string
    add_column :addresses, :address_line_2, :string
    add_column :addresses, :address_line_3, :string
  end
end
