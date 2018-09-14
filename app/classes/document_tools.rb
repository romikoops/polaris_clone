# frozen_string_literal: true

module DocumentTools
  include AwsConfig

  def update_file(file, shipment, type, _user)
    file_name = file.original_filename.gsub(/[^0-9A-Za-z.\-]/, '_')
    obj_key = Document.obj_key(shipment, type, file_name)
    Document.upload_doc(bucket: ENV['AWS_BUCKET'], key: obj_key, file: file.tempfile, content_type: file.content_type, acl: 'private')

    update_attributes!(
      url:         obj_key,
      text:        file_name,
      doc_type:    type
    )
    self
  end

  def self.new_upload(file, shipment, type, user)
    file_name = file.original_filename.gsub(/[^0-9A-Za-z.\-]/, '_')
    obj_key = Document.obj_key(shipment, type, file_name)
    Document.upload_doc(bucket: ENV['AWS_BUCKET'], key: obj_key, file: file.tempfile, content_type: file.content_type, acl: 'private')

    shipment.documents.create!(
      url:         obj_key,
      shipment_id: shipment['uuid'],
      text:        file_name,
      doc_type:    type,
      user_id:     user.id,
      tenant_id:   user.tenant_id
    )
  end

  def self.new_upload_backend(file, shipment, type, user)
    file_name = File.basename(file.path)
    obj_key = Document.obj_key(shipment, type, file_name)
    Document.upload_doc(bucket: ENV['AWS_BUCKET'], key: obj_key, file: file, content_type: 'application/pdf', acl: 'private')

    Document.create!(
      url:      obj_key,
      shipment: shipment,
      text:     file_name,
      doc_type: type,
      user:     user,
      tenant:   user.tenant
    )
  end

  def self.new_upload_backend_with_quotes(file, shipment, quotation, type, user)
    file_name = File.basename(file.path)
    obj_key = Document.obj_key(shipment, type, file_name)
    Document.upload_doc(bucket: ENV['AWS_BUCKET'], key: obj_key, file: file, content_type: 'application/pdf', acl: 'private')

    Document.create!(
      url:       obj_key,
      shipment:  shipment,
      text:      file_name,
      doc_type:  type,
      user:      user,
      quotation: quotation,
      tenant:    user.tenant
    )
  end
end
