# frozen_string_literal: true

class Hub < Legacy::Hub
  MOT_HUB_NAME = {
    "ocean" => "Port",
    "air" => "Airport",
    "rail" => "Railway Station"
  }.freeze

  self.per_page = 9

  def self.update_all!
    # This is a temporary method used for quick fixes in development

    hubs = Hub.all
    hubs.each do |h|
      h.nexus_id = h.address_id
      h.save!
    end
  end

  def self.update_type_availabilities_query_method
    truckings = ::Trucking::Trucking.joins(:location).where.not(hub_id: nil, trucking_locations: { distance: nil })

    uniq_truckings_attrs = truckings.distinct.select(:hub_id, :load_type, :carriage, :truck_type).as_json(except: :id)
    uniq_truckings_attrs.each do |trucking_attr_hsh|
      trucking_attr_hsh.symbolize_keys!
      hub_id = trucking_attr_hsh.delete(:hub_id)
      trucking_attr_hsh[:query_method] = :distance

      type_availability_id = ::Trucking::TypeAvailability.find_or_create_by(trucking_attr_hsh).id
      ::Trucking::HubAvailability.find_or_create_by(hub_id: hub_id, type_availability_id: type_availability_id)
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

  def self.create_from_nexus(nexus, mot, organization_id)
    nexus.hubs.find_or_create_by(
      nexus_id: nexus.id,
      organization_id: organization_id,
      hub_type: mot,
      latitude: nexus.latitude,
      longitude: nexus.longitude,
      name: nexus.name,
      photo: nexus.photo
    )
  end

  def self.ports
    where(hub_type: "ocean")
  end

  def self.prepped(user)
    where(organization_id: user.organization_id).map do |hub|
      { data: hub, address: hub.address.to_custom_hash }
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
        %w[pre on].each_with_object({}) do |carriage, carriage_obj|
          carriage_obj[carriage] = truck_type_availabilities.where(
            load_type: load_type,
            carriage: carriage
          ).pluck(:truck_type)
        end
    end
  end

  def available_trucking
    truck_type_availabilities.pluck(:load_type).uniq
  end

  def lat_lng_string
    "#{address.latitude},#{address.longitude}"
  end

  def lat_lng_array
    [address.latitude, address.longitude]
  end

  def lng_lat_array
    # loc = address
    [address.longitude, address.latitude]
  end

  def distance_to(loc)
    Geocoder::Calculations.distance_between([loc.latitude, loc.longitude], [address.latitude, address.longitude])
  end

  def toggle_hub_status!
    case hub_status
    when "active"
      assign_attributes(hub_status: "inactive")
    when "inactive"
      assign_attributes(hub_status: "active")
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
    dest_customs = customs_fees.find_by(
      load_type: load_type,
      direction: direction,
      mode_of_transport: mot,
      tenant_vehicle_id: tenant_vehicle_id,
      counterpart_hub_id: destination_hub_id
    )
    dest_customs || customs_fees.find_by(
      load_type: load_type,
      direction: direction,
      mode_of_transport: mot,
      tenant_vehicle_id: tenant_vehicle_id
    )
  end

  def as_options_json(options = {})
    new_options = options.reverse_merge(
      include: {
        nexus: { only: %i[id name] },
        address: {
          include: {
            country: { only: %i[name] }
          }
        }
      }
    )
    as_json(new_options)
  end
end

# == Schema Information
#
# Table name: hubs
#
#  id                  :bigint           not null, primary key
#  free_out            :boolean          default(FALSE)
#  hub_code            :string
#  hub_status          :string           default("active")
#  hub_type            :enum
#  latitude            :float
#  longitude           :float
#  name                :string
#  photo               :string
#  point               :geometry         geometry, 4326
#  terminal            :string
#  terminal_code       :string
#  trucking_type       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :integer
#  mandatory_charge_id :integer
#  nexus_id            :integer
#  organization_id     :uuid
#  sandbox_id          :uuid
#  tenant_id           :integer
#
# Indexes
#
#  hub_terminal_upsert            (nexus_id,name,hub_type,organization_id,terminal) UNIQUE
#  hub_upsert                     (nexus_id,hub_type,name,organization_id) UNIQUE WHERE (terminal IS NULL)
#  index_hubs_on_organization_id  (organization_id)
#  index_hubs_on_point            (point) USING gist
#  index_hubs_on_sandbox_id       (sandbox_id)
#  index_hubs_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
