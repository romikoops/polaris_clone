# frozen_string_literal: true
class AddDeletedAtToHubAvailabilities < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_hub_availabilities, :deleted_at, :datetime
  end
end
