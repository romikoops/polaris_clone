class Document < ApplicationRecord
  belongs_to :shipment
  belongs_to :user
  belongs_to :tenant

  def self.new_upload(file, shipment, type, user)
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    file_name = file.original_filename.gsub(/[^0-9A-Za-z.\-]/, '_')
    obj_key = 'documents/' + shipment['uuid'] +"/" + type + "/" + Time.now.to_i.to_s + '-' + file_name
    
    s3.put_object(
      bucket: 'imcdev', 
      key: obj_key, 
      body: file.tempfile, 
      content_type: file.content_type, 
      acl: 'private'
    )

    shipment.documents.create!(
      url: obj_key, 
      shipment_id: shipment['uuid'], 
      text: file_name, 
      doc_type: type, 
      user_id: user.id
    )
  end

  def self.new_upload_backend(file, shipment, type, user)
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    file_name = File.basename(file.path)
    obj_key = 'documents/' + shipment['uuid'] +"/" + type + "/" + file_name
    
    s3.put_object(
      bucket: 'imcdev', 
      key: obj_key, 
      body: file, 
      content_type: 'application/pdf', 
      acl: 'private'
    )
    shipment.documents.create!(
      url: obj_key, 
      shipment_id: shipment['uuid'], 
      text: file_name, 
      doc_type: type, 
      user_id: user.id
    )
  end

  def get_signed_url
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    signer = Aws::S3::Presigner.new({client: s3})
    
    @url = signer.presigned_url(:get_object, bucket: ENV['AWS_BUCKET'], key: self.url)  
  end

  def self.delete_document(id)
    @doc = Document.find(id)
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    s3.delete_object(bucket: 'imcdev', key: @doc.url)
    
    @doc.delete
  end
  def self.delete_all
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    @docs = Document.all
    @docs.each do |d|
      s3.delete_object(bucket: 'imcdev', key: d.url)
      d.delete
    end
  end
  def self.get_documents_for_array(arr)
    results = {}
    arr.each do |a|
      r = Document.where(shipment_id: a.id)
      results[a.id] = {}
      r.each do |dr|
        if dr.doc_type
          if !results[a.id][dr.doc_type] 
            results[a.id][dr.doc_type] = []
          end
          results[a.id][dr.doc_type].push(dr)
        else
          if !results[a.id]['packing_sheet'] 
            results[a.id]['packing_sheet'] = []
          end
          results[a.id]['packing_sheet'].push(dr)
        end
      end
       
    end
    return results
  end
end
