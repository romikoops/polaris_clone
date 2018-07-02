# frozen_string_literal: true

module AwsConfig
  def aws_signer
    Aws::S3::Presigner.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
  end

  def aws_client
    Aws::S3::Client.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
  end

  def awsurl
    "https://s3-eu-west-1.amazonaws.com/imcdev/"
  end

  def path(shipment)
    shipment.tenant.subdomain + "/documents/" + shipment["uuid"]
  end

  def create_on_aws(file, shipment)
    obj_key = path(shipment) + "/" + file.name
    public_awsurl = awsurl + obj_key
    aws_signer.put_object(bucket: ENV["AWS_BUCKET"], key: obj_key, body: file, content_type: file.content_type, acl: "private")
    shipment.documents.create(url: public_awsurl, shipment_id: shipment["uuid"], text: file.name)
  end

  def get_file_url(key)
    aws_signer.presigned_url(:get_object, bucket: ENV["AWS_BUCKET"], key: key)
  end

  def delete_documents(docs)
    docs.each do |doc|
      aws_client.delete_object(bucket: "imcdev", key: doc.url)
      doc.delete
    end
  end

  def upload(args={})
    aws_client.put_object(
      bucket:       args[:bucket],
      key:          args[:key],
      body:         args[:file],
      content_type: args[:content_type],
      acl:          args[:acl]
    )
  end
end
