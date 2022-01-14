# frozen_string_literal: true

class AddBranchIdToMembership < ActiveRecord::Migration[5.2]
  def change
    add_column :companies_memberships, :branch_id, :string
  end
end
