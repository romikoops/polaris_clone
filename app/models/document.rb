# frozen_string_literal: true

class Document < Legacy::Document
  has_one_attached :file
  belongs_to :shipment, optional: true
  belongs_to :tenant
  belongs_to :quotation, optional: true
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  def self.upload_doc(options)
    upload(options)
  end

  def self.obj_key(shipment, type, file_name)
    [
      'documents',
      ::Tenants::Tenant.find_by(legacy_id: shipment.tenant.id).slug,
      'shipments',
      shipment['uuid'],
      type,
      "#{Time.now.to_i}-#{file_name}"
    ].join('/')
  end

  def self.delete_document(id)
    doc = Document.where(id: id)
    delete_documents(doc) unless doc.empty?
  end

  def self.get_documents_for_array(arr)
    results = {}
    arr.each do |a|
      r = Document.where(shipment_id: a.id)
      results[a.id] = {}
      r.each do |dr|
        if dr.doc_type
          results[a.id][dr.doc_type] = [] unless results[a.id][dr.doc_type]
          results[a.id][dr.doc_type].push(dr)
        else
          results[a.id]['packing_sheet'] = [] unless results[a.id]['packing_sheet']
          results[a.id]['packing_sheet'].push(dr)
        end
      end
    end
    results
  end

  def get_signed_url
    @url = get_file_url(url)
  end
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
