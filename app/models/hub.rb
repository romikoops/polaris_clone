class Hub < ApplicationRecord
  belongs_to :tenant
  belongs_to :nexus, class_name: "Location", foreign_key: "location_id"

  has_many :schedules
  
  has_one :service_charge

  def generate_hub_code!(tenant_id)
    existing_hubs = self.nexus.hubs.where(hub_type: self.hub_type, tenant_id: tenant_id)
    num = existing_hubs.length
    letters = self.name[0..1].upcase
    type_letter = self.hub_type[0].upcase
    code = letters + type_letter + num.to_s
    self.hub_code = code
    self.save
  end

  def self.ports
    self.where(hub_type: "ocean")
  end
  def self.prepped_ports
    ports = self.where(hub_type: "ocean")
    resp = []
    ports.each do |po|
      resp << {data: po, location: po.nexus}
    end
    resp
  end

  def self.prepped(user)
    hubs = self.where(tenant_id: user.tenant_id)
    resp = []
    hubs.each do |po|
      resp << {data: po, location: po.nexus}
    end
    resp
  end

  def self.air_ports
    self.where(hub_type: "air")
  end

  def self.rail
    self.where(hub_type: "rail")
  end

  def lat_lng_string
    "#{latitude},#{longitude}"
  end

  def distance_to(loc)
    Geocoder::Calculations.distance_between([loc.latitude, loc.longitude], [self.latitude, self.longitude])
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
  end
end
