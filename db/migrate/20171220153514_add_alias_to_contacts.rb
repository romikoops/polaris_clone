# frozen_string_literal: true

class AddAliasToContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :contacts, :alias, :boolean, default: false
  end
end
