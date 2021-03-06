# frozen_string_literal: true

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
    lg_str = "test"
    # img.destroy!
    # resized_small.destroy!
    {sm: sm_str, lg: lg_str}
  end

  def load_city_images
    Dir.glob(Rails.root.to_s + "/images/*.jpg") do |image|
      file = image.split("/").last
      filename = file.split(".")[0]
      reduce_and_upload(filename, image)
    end
  end

  def upload_image(filepath)
    client = Aws::S3::Client.new
    filename = filepath[2..-1]
    key = "assets/default_images/" + filename
    File.open(filepath, "rb") do |file|
      client.put_object(bucket: Settings.aws.bucket, key: key, body: file, acl: "public-read")
    end
    "https://assets.itsmycargo.com/" + key
  end
end
