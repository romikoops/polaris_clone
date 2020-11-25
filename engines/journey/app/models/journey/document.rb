module Journey
  class Document < ApplicationRecord
    belongs_to :shipment_request
    belongs_to :query
    enum kind: {
      commercial_invoice: "commercial_invoice",
      dock_receipt: "dock_receipt",
      bill_of_lading: "bill_of_lading",
      certificate_of_origin: "certificate_of_origin",
      warehouse_receipt: "warehouse_receipt",
      inspection_certificate: "inspection_certificate",
      export_license: "export_license",
      packing_list: "packing_list",
      health_certificate: "health_certificate",
      insurance_certificate: "insurance_certificate",
      consular_documents: "consular_documents",
      free_trade_document: "free_trade_document",
      shippers_letter_of_instruction: "shippers_letter_of_instruction",
      destination_control_statement: "destination_control_statement"
    }
  end
end

# == Schema Information
#
# Table name: journey_documents
#
#  id                  :uuid             not null, primary key
#  kind                :enum
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  query_id            :uuid
#  shipment_request_id :uuid
#
# Indexes
#
#  index_journey_documents_on_kind                 (kind)
#  index_journey_documents_on_query_id             (query_id)
#  index_journey_documents_on_shipment_request_id  (shipment_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (query_id => journey_queries.id) ON DELETE => cascade
#  fk_rails_...  (shipment_request_id => journey_shipment_requests.id) ON DELETE => cascade
#
