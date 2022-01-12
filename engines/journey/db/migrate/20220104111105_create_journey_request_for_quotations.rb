# frozen_string_literal: true

class CreateJourneyRequestForQuotations < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_request_for_quotations, id: :uuid do |t|
      t.string :full_name, null: false
      t.string :phone, null: false
      t.string :email, null: false
      t.string :company_name
      t.text :note
      t.references :organization, type: :uuid, index: true,
                                  foreign_key: { to_table: "organizations_organizations" }
      t.references :query, type: :uuid, index: true, foreign_key: { to_table: "journey_queries" }

      t.timestamps
    end
  end
end
