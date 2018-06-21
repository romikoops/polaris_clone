# frozen_string_literal: true

module AwsConfig
  # class methods
  module ClassMethods
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
      "documents/" + shipment["uuid"]
    end

    def create_on_aws(file, shipment)
      obj_key = self.path(shipment) + "/" + file.name
      public_awsurl = self.awsurl + obj_key
      self.aws_signer.put_object(bucket: ENV["AWS_BUCKET"], key: obj_key, body: file, content_type: file.content_type, acl: "private")
      shipment.documents.create(url: public_awsurl, shipment_id: shipment["uuid"], text: file.name)
    end

    def get_file_url(key)
      self.aws_signer.presigned_url(:get_object, bucket: ENV["AWS_BUCKET"], key: key)
    end

    def delete_document(docs)
       docs.each do |doc|
        self.aws_client.delete_object(bucket: "imcdev", key: doc.url)
        doc.delete
      end
    end

    def upload(args={})
      self.aws_client.put_object(
        bucket:       args[:imcdev],
        key:          args[:key],
        body:         args[:file],
        content_type: args[:content_type],
        acl:          args[:acl]
      )
    end
  end

  # Instance methods
  module InstanceMethods
    def aws_signer
      self.class.aws_signer
    end

    def aws_client
      self.class.aws_client
    end

    def awsurl
      self.class.awsurl
    end

    def path(shipment)
      self.class.path(shipment)
    end

    def create_on_aws(file, shipment)
      self.class.create_on_aws(file, shipment)
    end

    def get_file_url(key)
      aws_signer.presigned_url(:get_object, bucket: ENV["AWS_BUCKET"], key: key)
    end

    def delete_document(docs)
      self.class.delete_document(docs)
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end
end
