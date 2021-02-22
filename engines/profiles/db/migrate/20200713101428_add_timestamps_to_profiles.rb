# frozen_string_literal: true
class AddTimestampsToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :profiles_profiles, null: false, default: -> { "NOW()" }
  end
end
