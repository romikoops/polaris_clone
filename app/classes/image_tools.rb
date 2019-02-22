# frozen_string_literal: true

module ImageTools
  require 'mini_magick'

  def reduce_and_upload(name, url)
    img = MiniMagick::Image.open(url)
    resized_small = img.resize '600x400'
    # resized_large = img.resize "800x600"
    resized_small.write("./#{name}_sm.jpg")
    # resized_large.write("./#{name}_lg.jpg")
    sm_str = upload_image("./#{name}_sm.jpg")
    # lg_str = upload_image("./#{name}_lg.jpg")
    lg_str = 'test'
    # img.destroy!
    # resized_small.destroy!
    { sm: sm_str, lg: lg_str }
  end

  def load_city_images
    Dir.glob(Rails.root.to_s + '/images/*.jpg') do |image|
      file = image.split('/').last
      filename = file.split('.')[0]
      resp = reduce_and_upload(filename, image)
    end
  end

  def upload_image(filepath)
    s3 = Aws::S3::Client.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region: Settings.aws.region
    )
    filename = filepath[2..-1]
    objKey = 'assets/default_images/' + filename
    File.open(filepath, 'rb') do |file|
      s3.put_object(bucket: Settings.aws.bucket, key: objKey, body: file, acl: 'public-read')
    end
    awsurl = 'https://assets.itsmycargo.com/' + objKey

    awsurl
  end
end
