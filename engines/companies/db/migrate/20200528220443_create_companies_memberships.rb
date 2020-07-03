# frozen_string_literal: true

class CreateCompaniesMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :companies_memberships, id: :uuid do |t|
      t.references :member, type: :uuid, polymorphic: true, index: true
      t.references :company, index: true, foreign_key: { to_table: :companies_companies }, type: :uuid

      t.timestamps
    end
  end
end
