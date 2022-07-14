# frozen_string_literal: true

class CreateLedgerServices < ActiveRecord::Migration[5.2]
  def change
    create_enum :modes_of_transport, Ledger::Service::MODES_OF_TRANSPORT

    create_table :ledger_services, id: :uuid do |t|
      t.references :routing
      t.references :carrier, type: :uuid, index: true, null: false, foreign_key: { to_table: "routing_carriers" }
      t.references :organization, type: :uuid, index: true, null: false, foreign_key: { to_table: "organizations_organizations" }
      t.string :name, null: false
      t.string :cargo_class
      t.enum :mode_of_transport, enum_type: :modes_of_transport
      t.string :origin_inland_cfs
      t.string :origin_cfs
      t.string :destination_cfs
      t.string :destination_inland_cfs

      t.timestamps
    end
  end
end
