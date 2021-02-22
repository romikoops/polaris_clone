# frozen_string_literal: true
class AddExternalIdToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles_profiles, :external_id, :string
  end
end
