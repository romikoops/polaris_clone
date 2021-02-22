# frozen_string_literal: true
class ChangeMetadataDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :trucking_truckings, :metadata, {}
  end
end
