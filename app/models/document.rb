# frozen_string_literal: true

class Document < Legacy::Document
  has_one_attached :file
  belongs_to :shipment, optional: true
  belongs_to :tenant
  belongs_to :quotation, optional: true
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
end

# == Schema Information
#
# Table name: documents
#
#  id               :bigint           not null, primary key
#  approval_details :jsonb
#  approved         :string
#  doc_type         :string
#  text             :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  quotation_id     :integer
#  sandbox_id       :uuid
#  shipment_id      :integer
#  tenant_id        :integer
#  user_id          :integer
#
# Indexes
#
#  index_documents_on_sandbox_id  (sandbox_id)
#  index_documents_on_tenant_id   (tenant_id)
#
