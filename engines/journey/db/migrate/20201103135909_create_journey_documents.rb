class CreateJourneyDocuments < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE journey_document_type AS ENUM ('commercial_invoice',
          'dock_receipt',
          'bill_of_lading',
          'certificate_of_origin',
          'warehouse_receipt',
          'inspection_certificate',
          'export_license',
          'packing_list',
          'health_certificate',
          'insurance_certificate',
          'consular_documents',
          'free_trade_document',
          'shippers_letter_of_instruction',
          'destination_control_statement');
      SQL
    end

    create_table :journey_documents, id: :uuid do |t|
      t.references :shipment_request, type: :uuid, index: true,
                                      foreign_key: {on_delete: :cascade, to_table: "journey_shipment_requests"}
      t.references :query, type: :uuid, index: true,
                           foreign_key: {on_delete: :cascade, to_table: "journey_queries"}
      t.column :kind, :journey_document_type, index: true
      t.timestamps
    end
  end

  def down
    drop_table :journey_documents

    safety_assured do
      execute <<-SQL
        DROP TYPE journey_document_type;
      SQL
    end
  end
end
