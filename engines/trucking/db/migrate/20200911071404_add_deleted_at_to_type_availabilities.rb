# frozen_string_literal: true
class AddDeletedAtToTypeAvailabilities < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_type_availabilities, :deleted_at, :datetime
  end
end
