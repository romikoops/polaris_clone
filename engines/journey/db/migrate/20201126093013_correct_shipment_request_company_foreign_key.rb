# frozen_string_literal: true
class CorrectShipmentRequestCompanyForeignKey < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_reference :journey_shipment_requests, :company, type: :uuid, index: true, foreign_key: {
        on_delete: :cascade, to_table: "users_users"
      }
      add_reference :journey_shipment_requests, :company, type: :uuid, foreign_key: {
        on_delete: :cascade, to_table: "companies_companies"
      }
    end
  end
end
