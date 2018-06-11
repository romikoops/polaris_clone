# frozen_string_literal: true

class AddPhotoToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :photo, :string
    add_column :hubs, :photo, :string
  end
end
