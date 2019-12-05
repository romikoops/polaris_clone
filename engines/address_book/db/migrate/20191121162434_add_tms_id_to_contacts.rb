# frozen_string_literal: true

class AddTmsIdToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :address_book_contacts, :tms_id, :string, index: true
  end
end
