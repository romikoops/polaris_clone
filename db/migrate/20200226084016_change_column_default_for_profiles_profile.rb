# frozen_string_literal: true

class ChangeColumnDefaultForProfilesProfile < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_column_null :profiles_profiles, :first_name, false
      change_column_null :profiles_profiles, :last_name, false
      change_column_default :profiles_profiles, :first_name, from: nil, to: ''
      change_column_default :profiles_profiles, :last_name, from: nil, to: ''
    end
  end
end
