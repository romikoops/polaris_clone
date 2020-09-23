# frozen_string_literal: true

module AwsConfig
  # class methods
  module ClassMethods
    def aws_signer
      Aws::S3::Presigner.new
    end

    def aws_client
      Aws::S3::Client.new
    end

    def awsurl
      'https://s3-eu-west-1.amazonaws.com/assets.itsmycargo.com/'
    end

    def path(shipment)
      slug = shipment.organization.slug

      "#{slug}/documents/#{shipment['uuid']}"
    end

    def create_on_aws(file, shipment)
      shipment.documents.create!(
        file: { io: file, filename: file.name, content_type: file.content_type },
        user_id: shipment.user_id,
        shipment_id: shipment['uuid'],
        text: file.name
      )
    end

    def upload(args = {})
      aws_client.put_object(
        bucket: args[:bucket],
        key: args[:key],
        body: args[:file],
        content_type: args[:content_type],
        acl: args[:acl]
      )
    end

    def asset_url
      'https://assets.itsmycargo.com/'
    end

    def save_asset(file, obj_key)
      aws_client.put_object(
        bucket: Settings.aws.bucket, key: obj_key, body: file,
        content_type: file.content_type, acl: 'public-read'
      )
    end
  end

  # Instance methods
  module InstanceMethods
    def asset_url
      self.class.asset_url
    end

    def save_asset(file, objKey)
      self.class.save_asset(file, objKey)
    end

    def aws_signer
      self.class.aws_signer
    end

    def aws_client
      self.class.aws_client
    end

    def awsurl
      'https://s3-eu-west-1.amazonaws.com/assets.itsmycargo.com/'
    end

    def path(shipment)
      self.class.path(shipment)
    end

    def create_on_aws(file, shipment)
      self.class.create_on_aws(file, shipment)
    end

    def get_file_url(key, bucket = Settings.aws.bucket)
      aws_signer.presigned_url(:get_object, bucket: bucket, key: key, response_content_disposition: 'attachment')
    end

    def upload(args = {})
      self.class.upload(args)
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end
end
