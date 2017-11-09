class Hub < ApplicationRecord
    belongs_to :tenant
  belongs_to :location
  
  has_one :service_charge

  def self.generate_hub_code(nexus, hub_name, type)
    existing_hubs = nexus.hubs.where(hub_type: type)
    num = existing_hubs.length + 1
    letters = hub_name[0..1].upcase
    type_letter = type[0].upcase
    code = letters + type_letter + num.to_s
    return code
  end

  def self.ports
    self.where(hub_type: "ocean")
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
