# frozen_string_literal: true

class Document < ApplicationRecord
  include AwsConfig
  belongs_to :shipment
  belongs_to :user
  belongs_to :tenant
  belongs_to :quotation, optional: true

  def self.upload_doc(options)
    upload(options)
  end

  def get_signed_url
    @url = get_file_url(url)
  end

  def self.obj_key(shipment, type, file_name)
    'documents/' + shipment.tenant.subdomain + '/shipments/' + shipment['uuid'] + '/' + type + '/' + Time.now.to_i.to_s + '-' + file_name
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
end
