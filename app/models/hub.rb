class Hub < ApplicationRecord

  belongs_to :tenant
  belongs_to :nexus, class_name: "Location"
  belongs_to :location

  has_many :stops,    dependent: :destroy
  has_many :layovers, through: :stops
  has_many :hub_truckings
  has_many :trucking_pricings, through: :hub_truckings
  has_many :local_charges
  has_many :customs_fees
  has_many :notes,     dependent: :destroy
  belongs_to :mandatory_charge, optional: true


  MOT_HUB_NAME = {
    "ocean" => "Port",
    "air"   => "Airport",
    "rail"  => "Railway Station"    
  }

  def self.update_all!
    # This is a temporary method used for quick fixes in development

    hubs = Hub.all
    hubs.each do |h|
      h.nexus_id = h.location_id
      h.save!
    end
  end

  def self.create_from_nexus(nexus, mot, tenant_id)    
    nexus.hubs.find_or_create_by(
      nexus_id: nexus.id,
      tenant_id: tenant_id,
      hub_type: mot,
      latitude: nexus.latitude,
      longitude: nexus.longitude,
      name: "#{nexus.name} #{MOT_HUB_NAME[mot]}",
      photo: nexus.photo
    )
  end

  def self.ports
    self.where(hub_type: "ocean")
  end

  def self.prepped(user)
    where(tenant_id: user.tenant_id).map do |hub|
      { data: hub, location: hub.nexus }
    end
  end

  def self.air_ports
    self.where(hub_type: "air")
  end

  def self.rail
    self.where(hub_type: "rail")
  end

  def generate_hub_code!(tenant_id)
    existing_hubs = self.nexus.hubs.where(hub_type: self.hub_type, tenant_id: tenant_id)
    num = existing_hubs.length
    letters = self.name[0..1].upcase
    type_letter = self.hub_type[0].upcase
    code = letters + type_letter + num.to_s
    self.hub_code = code
    self.save
  end

  def lat_lng_string
    "#{location.latitude},#{location.longitude}"
  end

  def distance_to(loc)
    Geocoder::Calculations.distance_between([loc.latitude, loc.longitude], [self.location.latitude, self.location.longitude])
  end

  def toggle_hub_status!
    case self.hub_status
    when "active"
      self.update_attribute(:hub_status, "inactive")
    when "inactive"
      self.update_attribute(:hub_status, "active")
    else
      raise "Location contains invalid hub status!"
    end
    self.save!
  end
end
