class TruckingPricing < ApplicationRecord
  has_many :shipments
  belongs_to :courier
  belongs_to :tenant
  has_many :hub_truckings, dependent: :destroy
  has_many :hubs, through: :hub_truckings
  has_many :trucking_destinations, through: :hub_truckings
  extend MongoTools
  # Validations

  # Class methods
  def self.copy_to_tenant(from_tenant, to_tenant)
    ft = Tenant.find_by_subdomain(from_tenant)
    tt = Tenant.find_by_subdomain(to_tenant)
    ft.trucking_pricings.each do |tp|
      temp_tp = tp.as_json
      temp_tp.delete("id")
      hub_id = Hub.find_by(name: Hub.find(tp.hub_id).name, tenant_id: tt.id).id

      temp_tp["tenant_id"] = tt.id
      ntp = TruckingPricing.create!(temp_tp)
      hts = tp.hub_truckings
      nhts = hts.map do |ht| 
        temp_ht = ht.as_json
        temp_ht.delete("id")
        temp_ht["hub_id"] = hub_id
        temp_ht["trucking_pricing_id"] = ntp.id
        HubTrucking.create!(temp_ht)
      end
    end
  end
  
  def self.fix_hub_truckings(subd)
    t = Tenant.find_by_subdomain(subd)
    t.trucking_pricings.map do |tp|
      hub = Hub.find(tp.hub_id)
      if hub.tenant_id != t.id
        new_hub = Hub.find_by(name: hub.name, tenant_id: t.id)
        tp.hub_truckings.each do |ht|
          ht.hub_id = new_hub.id
          ht.save!
        end
      end
    end
  end

  def self.find_by_filter(args = {})
    find_by_filter_argument_errors(args)

    latitude     = args[:latitude]     || args[:location].try(:latitude)  || 0
    longitude    = args[:longitude]    || args[:location].try(:longitude) || 0
    zipcode      = args[:zipcode]      || args[:location].try(:get_zip_code)
    city_name    = args[:city_name]    || args[:location].try(:city)
    country_code = args[:country_code] || args[:location].try(:country).try(:code)

    joins(hub_truckings: [:trucking_destination, hub: :nexus])
      .where('hubs.tenant_id': args[:tenant_id])
      .where('trucking_pricings.load_type': args[:load_type])
      .where('trucking_pricings.carriage': args[:carriage])
      .where('trucking_destinations.country_code': country_code)
      .where(cargo_class_condition(args))
      .where(truck_type_condition(args))
      .where(nexuses_condition(args))
      .where("
        (
          (trucking_destinations.zipcode IS NOT NULL)
          AND (trucking_destinations.zipcode = :zipcode)
        ) OR (
          (trucking_destinations.geometry_id IS NOT NULL)
          AND (
            SELECT ST_Contains(
              (SELECT data::geometry FROM geometries WHERE id = trucking_destinations.geometry_id),
              (SELECT ST_Point(:longitude, :latitude)::geometry)
            ) AS contains
          )          
        ) OR (
          (trucking_destinations.distance IS NOT NULL)
          AND (
            trucking_destinations.distance = (
              SELECT ROUND(ST_Distance(
                ST_Point(hubs.longitude, hubs.latitude)::geography,
                ST_Point(:longitude, :latitude)::geography
              ) / 500)
            )
          )
        )        
      ", zipcode: zipcode, city_name: city_name, latitude: latitude, longitude: longitude)

  end


  def self.find_by_hub_ids(args = {})
    hub_ids = args[:hub_ids]
    raise ArgumentError, "Must provide hub_ids"   if hub_ids.nil?
    raise ArgumentError, "Must provide tenant_id" if args[:tenant_id].nil?

    sanitized_query = sanitize_sql(["
      SELECT trucking_pricings.id, (
        CASE
          WHEN MAX(trucking_destinations.zipcode) != '0'
            THEN ('zipcode', MIN(trucking_destinations.zipcode), MAX(trucking_destinations.zipcode))
          WHEN MAX(trucking_destinations.distance) != '0'
            THEN ('distance', MIN(trucking_destinations.distance), MAX(trucking_destinations.distance))
          ELSE
            ('city', MAX(trucking_destinations.city_name))
        END
      ) AS filter
      FROM  trucking_pricings
      JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
      JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
      JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
      JOIN  locations             ON hubs.location_id                      = locations.id
      JOIN  tenants               ON hubs.tenant_id                        = tenants.id
      WHERE tenants.id = :tenant_id
      AND   hubs.id IN (:hub_ids)
      GROUP BY trucking_pricings.id
      ORDER BY MAX(trucking_destinations.zipcode), MAX(trucking_destinations.distance), MAX(trucking_destinations.city_name)
    ", tenant_id: args[:tenant_id], hub_ids: hub_ids])

    connection.exec_query(sanitized_query).map do |row|
      filter = parse_sql_record(row["filter"])
      {
        "truckingPricing" => find(row["id"]),
        filter.first      => filter[1..-1]
      }
    end
  end

  # Instance Methods
  def nexus_id
    ActiveRecord::Base.connection.execute("
      SELECT locations.id FROM locations
      JOIN hubs ON hubs.nexus_id = locations.id
      JOIN hub_truckings ON hub_truckings.hub_id = hubs.id
      JOIN trucking_pricings ON hub_truckings.trucking_pricing_id = trucking_pricings.id
      WHERE trucking_pricings.id = #{self.id}
      LIMIT 1
    ").values.first.try(:first)
  end

  def hub_id
    ActiveRecord::Base.connection.execute("
      SELECT hubs.id FROM hubs
      JOIN hub_truckings ON hub_truckings.hub_id = hubs.id
      JOIN trucking_pricings ON hub_truckings.trucking_pricing_id = trucking_pricings.id
      WHERE trucking_pricings.id = #{self.id}
      LIMIT 1
    ").values.first.try(:first)
  end

  def values_without_rates_and_fees
    %w(carriage cbm_ratio courier_id load_meterage load_type modifier tenant_id truck_type).sort.map do |key|
      self[key.to_sym]
    end.join(", ")
  end

  private

  def self.find_by_filter_argument_errors(args)
    mandatory_args = [:load_type, :tenant_id, :carriage]

    mandatory_args.each do |mandatory_arg|
      raise ArgumentError, "Must provide #{mandatory_arg}" if args[mandatory_arg].nil?
    end

    if args[:location].try(:country).try(:code).nil? && args[:country_code].nil?
      raise ArgumentError, "Must provide country_code"
    end

    if args.keys.size <= mandatory_args.length
      raise ArgumentError, "Must provide a valid filter besides #{mandatory_args.to_sentence}"
    end
  end

  def self.truck_type_condition(args)
    args[:truck_type] ? { 'trucking_pricings.truck_type': args[:truck_type] } : {}
  end

  def self.cargo_class_condition(args)
    args[:cargo_class] ? { 'trucking_pricings.cargo_class': args[:cargo_class] } : {}
  end

  def self.nexuses_condition(args)
    args[:nexus_ids] ? { 'hubs.nexus_id': args[:nexus_ids] } : {}
  end

  def self.parse_sql_record(str)
    str.gsub(/\(|\)|\"/, "").split(",")
  end
end
