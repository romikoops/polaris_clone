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
    "documents/" + shipment["uuid"]
  end
end