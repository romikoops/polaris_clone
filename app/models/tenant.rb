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
  has_many :itineraries
  has_many :stops, through: :itineraries
  has_many :trips, through: :itineraries
  has_many :layovers, through: :stops
    
  validates :scope, presence: true, scope: true

  def get_admin
    self.users.where(role_id: 1).first
  end

  def update_route_details
    itineraries = Itinerary.where(tenant_id: self.id)
    detailed_itineraries = itineraries.map do |itinerary, h|
      itinerary.set_scope!

      itinerary.routes
    end
    # put_item('itinerarieOptions', {id: self.id, data: detailed_itineraries})
    update_item('itineraryOptions', {id: self.id}, {data: detailed_itineraries.flatten})
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
  def self.update_web
    web_data = [
      {subdomain: "greencarrier", cloudfront: 'E1HIJBT7WVXAP3'},
      {subdomain: "demo", cloudfront: 'E20JU5F52LP1AZ', index: 'index.html'},
      {subdomain: "nordicconsolidators", cloudfront: 'E3P24SVVXVUTZO'},
      {subdomain: "isa", cloudfront: 'E33QYEB8CF5AW0'},
      {subdomain: "integrail", cloudfront: 'E1WJTKUIV6CYP3'},
      {subdomain: "easyshipping", cloudfront: 'E2VR366CPGNLTC'},
      {subdomain: "belglobe", cloudfront: 'E42GZPFHU0WZO'},
      {subdomain: "eimskip", cloudfront: 'E1XPLYJA1HASN3'},
    ]
    web_data.each do |wd|
      t = Tenant.find_by_subdomain(wd[:subdomain])
      if !t.web
        t.web = {}
      end
      t.web[:sudomain] = wd[:subdomain]
      t.web[:cloudfront] = wd[:cloudfront]
      t.save!
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
