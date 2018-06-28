# frozen_string_literal: true

class Hub < ApplicationRecord
  belongs_to :tenant
  belongs_to :nexus, class_name: "Location"
  belongs_to :location

  has_many :stops,    dependent: :destroy
  has_many :layovers, through: :stops
  has_many :hub_truckings
  has_many :trucking_pricings, -> { distinct }, through: :hub_truckings
  has_many :local_charges
  has_many :customs_fees
  has_many :notes, dependent: :destroy
  has_many :hub_truck_type_availabilities
  has_many :truck_type_availabilities, through: :hub_truck_type_availabilities
  belongs_to :mandatory_charge, optional: true

  MOT_HUB_NAME = {
    "ocean" => "Port",
    "air"   => "Airport",
    "rail"  => "Railway Station"
  }.freeze

  def self.update_all!
    # This is a temporary method used for quick fixes in development

    hubs = Hub.all
    hubs.each do |h|
      h.nexus_id = h.location_id
      h.save!
    end
  end

  def self.group_ids_by_nexus(hub_ids)
    sanitized_query = sanitize_sql(["
      SELECT
        hubs.nexus_id,
        STRING_AGG(hubs.id::text, ',') AS serialized_hub_ids
      FROM hubs
      WHERE hubs.id IN (?)
      GROUP BY hubs.nexus_id
    ", hub_ids])

    groups = connection.execute(sanitized_query).to_a
    groups.each_with_object({}) do |group, obj|
      obj[group["nexus_id"]] = group["serialized_hub_ids"].split(",").map(&:to_i)
    end
  end

  def self.create_from_nexus(nexus, mot, tenant_id)
    nexus.hubs.find_or_create_by(
      nexus_id:  nexus.id,
      tenant_id: tenant_id,
      hub_type:  mot,
      latitude:  nexus.latitude,
      longitude: nexus.longitude,
      name:      "#{nexus.name} #{MOT_HUB_NAME[mot]}",
      photo:     nexus.photo
    )
  end

  def self.ports
    where(hub_type: "ocean")
  end

  def self.prepped(user)
    where(tenant_id: user.tenant_id).map do |hub|
      { data: hub, location: hub.location.to_custom_hash }
    end
  end

  def self.air_ports
    where(hub_type: "air")
  end

  def self.rail
    where(hub_type: "rail")
  end

  def truck_type_availability
    Shipment::LOAD_TYPES.each_with_object({}) do |load_type, load_type_obj|
      load_type_obj[load_type] =
        %w(pre on).each_with_object({}) do |carriage, carriage_obj|
          carriage_obj[carriage] = truck_type_availabilities.where(
            load_type: load_type,
            carriage:  carriage
          ).pluck(:truck_type)
        end
    end
  end

  def generate_hub_code!(tenant_id)
    existing_hubs = nexus.hubs.where(hub_type: hub_type, tenant_id: tenant_id)
    num = existing_hubs.length
    letters = name[0..1].upcase
    type_letter = hub_type[0].upcase
    code = letters + type_letter + num.to_s
    self.hub_code = code
    save
  end

  def lat_lng_string
    "#{location.latitude},#{location.longitude}"
  end

  def lat_lng_array
    [location.latitude, location.longitude]
  end
  def lng_lat_array
    # loc = location
    [location.longitude, location.latitude]
  end

  def distance_to(loc)
    Geocoder::Calculations.distance_between([loc.latitude, loc.longitude], [location.latitude, location.longitude])
  end

  def toggle_hub_status!
    case hub_status
    when "active"
      update_attribute(:hub_status, "inactive")
    when "inactive"
      update_attribute(:hub_status, "active")
    else
      raise "Location contains invalid hub status!"
    end
    save!
  end

  def copy_to_hub(hub_id)
    hub_truckings.each do |ht|
      nht = ht.as_json
      nht.delete("id")
      nht["hub_id"] = hub_id
      tp = ht.trucking_pricing
      ntp = tp.as_json
      ntp.delete("id")
      ntps = TruckingPricing.create!(ntp)
      nht["trucking_pricing_id"] = ntps.id
      HubTrucking.create!(nht)
    end
  end
  def get_customs(load_type, mot, direction, tenant_vehicle_id, destination_hub_id)
    dest_customs = self.customs_fees.find_by(
      load_type: load_type,
      direction: direction,
      mode_of_transport: mot, 
      tenant_vehicle_id: tenant_vehicle_id,
      counterpart_hub_id: destination_hub_id
    )
    if dest_customs
      return dest_customs
    else
      customs = self.customs_fees.find_by(
        load_type: load_type,
        direction: direction,
        mode_of_transport: mot, 
        tenant_vehicle_id: tenant_vehicle_id
      )
      return customs
    end
  end

  def as_options_json(options={})
    new_options = options.reverse_merge(
      include: {
        nexus:    { only: %i[id name] },
        location: {
          include: {
            country: { only: %i[name]}
          }
        }
      }
    )
    as_json(new_options)
  end
end
