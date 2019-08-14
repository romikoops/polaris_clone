# frozen_string_literal: true

class Document < Legacy::Document
  has_one_attached :file
  belongs_to :shipment, optional: true
  belongs_to :user, optional: true
  belongs_to :tenant
  belongs_to :quotation, optional: true
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  def self.upload_doc(options)
    upload(options)
  end

  def self.obj_key(shipment, type, file_name)
    [
      'documents',
      shipment.tenant.subdomain,
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

  def local_file_path
    ActiveStorage::Blob.service.send(:path_for, file.key)
  end
end

# == Schema Information
#
# Table name: documents
#
#  id               :bigint(8)        not null, primary key
#  user_id          :integer
#  shipment_id      :integer
#  doc_type         :string
#  url              :string
#  text             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  approved         :string
#  approval_details :jsonb
#  tenant_id        :integer
#  quotation_id     :integer
#  sandbox_id       :uuid
#
