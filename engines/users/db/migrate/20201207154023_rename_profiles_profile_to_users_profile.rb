# frozen_string_literal: true
class RenameProfilesProfileToUsersProfile < ActiveRecord::Migration[5.2]
  def change
    # Accept downtime deployment
    safety_assured do
      rename_table :profiles_profiles, :users_profiles
    end
  end
end
