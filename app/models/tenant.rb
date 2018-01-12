class Tenant < ApplicationRecord
  include ImageTools
  include MongoTools

  has_many :routes
  has_many :hubs
  has_many :routes
  has_many :hub_routes, through: :routes
  has_many :schedules
  has_many :users
  has_many :tenant_vehicles
  has_many :vehicles, through: :tenant_vehicles
    
  def test
    # str =  Rails.root + '/app/assets/images/cityimages/Hanoi.jpg'
    # p str
    # Dir.glob(Rails.root.to_s + '/app/assets/images/cityimages/*.jpg') do |image|
    #   p image
    #   
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
  # Generates the static info for the choose route page
  def update_route_details
    routes = Route.where(tenant_id: self.id)
    detailed_routes = routes.map do |route| 
      route.detailed_hash(
        nexus_names: true, 
        modes_of_transport: true
      )
    end
    put_item('routeOptions', {id: self.id, data:detailed_routes})
  end

  def mot_scope(args)
    mot = scope["modes_of_transport"]
    mot = load_type_filter("container", mot)  if args[:only_container]
    mot = load_type_filter("cargo_item", mot) if args[:only_cargo_item]

    MotScope.find_by(mot_scope_attributes(mot))
  end

  private
  
  def load_type_filter(load_type, mot)
    mot.each_with_object({}) do |(k, v), h|
      h[k] = v.each_with_object({}) { |(_k, _v), _h| _h[_k] = _k != load_type ? false : _v }
    end
  end
  
  def mot_scope_attributes(mot)
    # applies the following conversion in order to get the attributes which find the MotScope: 
    #       
    #               mot                        --->          mot_scope_attributes
    #       
    # { air: { container: true, ... }, ...}    --->    { "air_container" => true, ... }
    
    mot.reduce({}) do |h, (k, v)|
      h.merge v.each_with_object({}) { |(_k, _v), _h| _h["#{k}_#{_k}"] = _v }
    end
  end
end
