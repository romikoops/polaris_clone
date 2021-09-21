# frozen_string_literal: true

class AddShipmentRequestAttributes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE shipment_request_status AS ENUM (
          'requested',
          'in_progress',
          'rejected',
          'completed'
        );
      SQL
    end

    add_column :journey_shipment_requests, :with_customs_handling, :boolean
    change_column_default :journey_shipment_requests, :with_customs_handling, false

    add_column :journey_shipment_requests, :with_insurance, :boolean
    change_column_default :journey_shipment_requests, :with_insurance, false

    add_monetize :journey_shipment_requests, :commercial_value, amount: { null: true, default: nil }, currency: { null: true, default: nil }

    add_column :journey_shipment_requests, :notes, :text, null: true
    add_column :journey_shipment_requests, :status, :shipment_request_status

    add_index :journey_shipment_requests, :status, algorithm: :concurrently
  end

  def down
    remove_index :journey_shipment_requests, :status
    remove_column :journey_shipment_requests, :status
    remove_column :journey_shipment_requests, :notes
    remove_monetize :journey_shipment_requests, :commercial_value
    remove_column :journey_shipment_requests, :with_insurance
    remove_column :journey_shipment_requests, :with_customs_handling

    safety_assured do
      execute <<-SQL
        DROP TYPE shipment_request_status
      SQL
    end
  end
end
