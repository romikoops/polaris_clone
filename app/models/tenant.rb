class Tenant < ApplicationRecord
  include ImageTools
    has_many :routes
    has_many :hubs
    has_many :routes
    has_many :users
    has_many :tenant_vehicles
    has_many :vehicles, through: :tenant_vehicles
    
  def test
    # str =  Rails.root + '/app/assets/images/cityimages/Hanoi.jpg'
    # p str
    # Dir.glob(Rails.root.to_s + '/app/assets/images/cityimages/*.jpg') do |image|
    #   p image
    #   byebug
    #   # resp = reduce_and_upload('Hanoi', str)
    #   # p resp[:sm]
    # end
    # Dir.foreach(Rails.root.to_s + '/app/assets/welcome') do |image|
    #   next if image == '.' or image == '..'
    #   filename
    #   path = Rails.root.to_s + '/app/assets/welcome/' + image
    #   resp = reduce_and_upload(image, path)
    #   p resp[:sm]
    # end
    load_city_images
  end
end
