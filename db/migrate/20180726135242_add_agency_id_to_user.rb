# frozen_string_literal: true

class AddAgencyIdToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :agency_id, :integer
  end
end
