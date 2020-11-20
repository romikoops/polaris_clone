# frozen_string_literal: true

class BackfillNameColumnsOnProfiles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    Profiles::Profile.where(first_name: nil).update(first_name: "")
    Profiles::Profile.where(last_name: nil).update(last_name: "")
  end
end
