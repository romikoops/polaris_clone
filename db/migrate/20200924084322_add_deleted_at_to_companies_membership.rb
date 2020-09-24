# frozen_string_literal: true

class AddDeletedAtToCompaniesMembership < ActiveRecord::Migration[5.2]
  def change
    add_column :companies_memberships, :deleted_at, :datetime
  end
end
