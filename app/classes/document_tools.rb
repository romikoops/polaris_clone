module DocumentTools	
def create(file, shipment)
		s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    # tixObj = firebase.get("tix/" + tid)
    objKey = 'documents/' + shipment['uuid'] +"/" + file.name
		
    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: file.content_type, acl: 'private')
		shipment.documents.create(url: awsurl, shipment_id: shipment['uuid'], text: file.name)
	end
	
	def get_file_url(key)
		# signer = Aws::S3::Presigner.new(
  #     access_key_id: ENV['AWS_KEY'],
  #     secret_access_key: ENV['AWS_SECRET'],
  #     region: ENV['AWS_REGION']
  #   )
  signer = Aws::S3::Presigner.new(
      :access_key_id => ENV['AWS_KEY'],
      :secret_access_key => ENV['AWS_SECRET'],
      :region => ENV['AWS_REGION']
    )
    byebug
 		@url = signer.presigned_url(:get_object, bucket: ENV['AWS_BUCKET'], key: key)	
	end
end