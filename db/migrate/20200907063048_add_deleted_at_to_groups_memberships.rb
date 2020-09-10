# frozen_string_literal: true

class AddDeletedAtToGroupsMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :groups_groups, :deleted_at, :datetime
    add_column :groups_memberships, :deleted_at, :datetime
  end
end
