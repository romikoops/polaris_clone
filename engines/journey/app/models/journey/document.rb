# frozen_string_literal: true

module Journey
  class Document < ApplicationRecord
    VALID_CONTENT_TYPES = {
      ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      ".doc" => "application/msword",
      ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      ".xls" => "application/vnd.ms-excel",
      ".pdf" => "application/pdf",
      ".jpg" => "image/jpeg",
      ".jpeg" => "image/jpeg",
      ".png" => "image/png"
    }.freeze
    MAX_FILE_SIZE_IN_MB = 20
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
    has_one_attached :file

    validate :file_presence, :correct_file_mime_type, :attachment_size_limits, on: :create

    private

    def file_presence
      return errors.add(:file, error_code: "FILE_MISSING", error_message: "File must be present") unless file.attached?
    end

    def correct_file_mime_type
      return unless file.attached?
      return if file.content_type.in?(VALID_CONTENT_TYPES.values.flatten)

      errors.add(:file, error_code: "INVALID_CONTENT_TYPE", error_message: "Must be one of the following file types: #{VALID_CONTENT_TYPES.keys.join(', ')}")
    end

    def attachment_size_limits
      return unless file.attached?
      return unless file.blob.byte_size > MAX_FILE_SIZE_IN_MB.megabytes

      errors.add(:file, error_code: "INVALID_FILE_SIZE", error_message: "Must be smaller than #{MAX_FILE_SIZE_IN_MB}mb.")
    end
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
