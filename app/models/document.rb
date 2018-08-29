# frozen_string_literal: true

class Document < ApplicationRecord
  include AwsConfig
  belongs_to :shipment
  belongs_to :user
  belongs_to :tenant

  def self.new_upload(file, shipment, type, user)
    file_name = file.original_filename.gsub(/[^0-9A-Za-z.\-]/, "_")
    obj_key = self.obj_key(shipment, type, file_name)
    upload(bucket: "imcdev", key: obj_key, file: file.tempfile, content_type: file.content_type, acl: "private")

    shipment.documents.create!(
      url:         obj_key,
      shipment_id: shipment["uuid"],
      text:        file_name,
      doc_type:    type,
      user_id:     user.id,
      tenant_id:   user.tenant_id
    )
  end

  def self.new_upload_backend(file, shipment, type, user)
    file_name = File.basename(file.path)
    obj_key = self.obj_key(shipment, type, file_name)
    upload(bucket: "imcdev", key: obj_key, file: file, content_type: "application/pdf", acl: "private")

    Document.create!(
      url:      obj_key,
      shipment: shipment,
      text:     file_name,
      doc_type: type,
      user:     user,
      tenant:   user.tenant
    )
  end

  # def self.new_upload_backend_with_quotes(file, shipment, quotes, type, user)
  #   file_name = File.basename(file.path)
  #   obj_key = self.obj_key(shipment, type, file_name)
  #   byebug
  #   upload(bucket: "imcdev", key: obj_key, file: file, content_type: "application/pdf", acl: "private")

  #   Document.create!(
  #     url:      obj_key,
  #     shipment: shipment,
  #     text:     file_name,
  #     doc_type: type,
  #     quotes:   quotes,
  #     user:     user,
  #     tenant:   user.tenant
  #   )
  # end

  def get_signed_url
    @url = get_file_url(url)
  end

  def self.obj_key(shipment, type, file_name)
     "documents/" + shipment.tenant.subdomain + "/shipments/" + shipment["uuid"] + "/" + type + "/" + Time.now.to_i.to_s + "-" + file_name
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
          results[a.id]["packing_sheet"] = [] unless results[a.id]["packing_sheet"]
          results[a.id]["packing_sheet"].push(dr)
        end
      end
    end
    results
  end
end
