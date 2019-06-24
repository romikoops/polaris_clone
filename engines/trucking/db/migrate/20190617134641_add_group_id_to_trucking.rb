# frozen_string_literal: true

class AddGroupIdToTrucking < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_truckings, :group_id, :uuid, index: true
  end
end
