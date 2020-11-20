# frozen_string_literal: true

class CreateProfilesProfile < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles_profiles, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.string :phone
      t.references :user, type: :uuid, unique: true, foreign_key: {to_table: :tenants_users, on_delete: :cascade}
    end
  end
end
