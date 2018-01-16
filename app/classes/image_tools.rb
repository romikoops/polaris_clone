module ImageTools
  require "mini_magick"

  def reduce_and_upload(name, url)
    img = MiniMagick::Image.open(url)
    resized_small = img.resize "600x400"
    # resized_large = img.resize "800x600"
    resized_small.write("./#{name}_sm.jpg")
    # resized_large.write("./#{name}_lg.jpg")
    sm_str = upload_image("./#{name}_sm.jpg")
    # lg_str = upload_image("./#{name}_lg.jpg")
    lg_str = 'test'
    # img.destroy!
    # resized_small.destroy!
    return {sm: sm_str, lg: lg_str}
  end

  def load_city_images
    Dir.glob(Rails.root.to_s + '/images/*.jpg') do |image|
      file = image.split('/').last
      filename = file.split('.')[0]
      resp = reduce_and_upload(filename, image)
      p resp[:sm]
    end
  end

  def upload_image(filepath)
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    filename = filepath[2..-1]
    objKey = 'assets/default_images/' + filename
    File.open(filepath, 'rb') do |file|
      s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body:file, acl: 'public-read')
    end
    # s3.bucket(ENV['AWS_BUCKET']).object(objKey).upload_file(filepath)
    awsurl = "https://assets.itsmycargo.com/" + objKey

    return awsurl
    # s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: file.content_type, acl: 'public-read')
  end
end
