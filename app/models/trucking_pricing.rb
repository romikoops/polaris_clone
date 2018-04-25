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
  def self.update_data
    HubTrucking.where(hub_id: 258).each do |ht|
      ht.hub_id = 411
      ht.save!
    end
    # TruckingPricing.where(.each do |tp|
    #   hub_id = tp.hub_id
    #   if hub_id
    #     hub = Hub.find(hub_id)
    #     if hub
    #       t = hub.tenant
    #       tp.tenant_id = t.id
    #     else
    #       next
    #     end
    #   else
    #     next
    #   end
    #   # tp.load_type = tp.load_type == 'fcl' ? 'container' : 'cargo_item'
    #   tp.export = tp.import if tp.export == {"table" => []}
    #   tp.import = tp.export if tp.import == {"table" => []}
    #   # tp.truck_type =  "default" if tp.load_type != 'container'
    #   tp.truck_type = "chassis" if tp.truck_type == "chassi"
    #   # if tp.export
    #   #   tp.export["table"].each do |cell|
    #   #     if cell && cell["fees"]["congestion"]
    #   #       cell["fees"]["congestion"]["rate_basis"] = "PER_SHIPMENT"
    #   #       # cell["fees"].delete("type")
    #   #       # cell["fees"].delete("direction")
    #   #     end
    #   #   end
    #   # end
    #   # if tp.import
    #   #   tp.import["table"].each do |cell|
    #   #     if cell && cell["fees"]["congestion"]
    #   #       cell["fees"]["congestion"]["rate_basis"] = "PER_SHIPMENT"
    #   #       # cell["fees"].delete("type")
    #   #       # cell["fees"].delete("direction")
    #   #     end
    #   #   end
    #   # end
    #   if tp.load_meterage
    #     tp.load_meterage["ratio"] = 1950
    #     tp.cbm_ratio = 280
    #   else
    #     tp.cbm_ratio = 250
    #   end
    #   tp.save!
    # end
  end

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

    latitude  = args[:latitude]  || args[:location].try(:latitude)  || 0
    longitude = args[:longitude] || args[:location].try(:longitude) || 0
    zipcode   = args[:zipcode]   || args[:location].try(:get_zip_code)
    city_name = args[:city_name] || args[:location].try(:city)
    carriage  = args[:carriage]

    ids = ActiveRecord::Base.connection.execute("
      SELECT trucking_pricings.id FROM trucking_pricings
      JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
      JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
      JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
      JOIN  locations             ON hubs.nexus_id                         = locations.id
      JOIN  tenants               ON hubs.tenant_id                        = tenants.id
      WHERE tenants.id = #{args[:tenant_id]}
      AND trucking_pricings.load_type = '#{args[:load_type]}'
      AND trucking_pricings.carriage = '#{carriage}'
      #{truck_type_condition(args)}
      #{nexuses_condition(args)}
      AND (
        (
          (trucking_destinations.zipcode IS NOT NULL)
          AND (trucking_destinations.zipcode = '#{zipcode}')
        ) OR (
          (trucking_destinations.city_name IS NOT NULL)
          AND (trucking_destinations.city_name = '#{city_name}')
        ) OR (
          (trucking_destinations.distance IS NOT NULL)
          AND (
            trucking_destinations.distance = (
              SELECT ROUND(ST_Distance(
                ST_Point(hubs.longitude, hubs.latitude)::geography,
                ST_Point(#{longitude}, #{latitude})::geography
              ) / 500)
            )
          )
        )
      )
    ").values.flatten

    TruckingPricing.where(id: ids)
  end


  def self.find_by_hub_ids(args = {})
    hub_ids = args[:hub_ids]
    raise ArgumentError, "Must provide hub_ids" if hub_ids.nil?
    raise ArgumentError, "Must provide tenant_id" if args[:tenant_id].nil?

    result = ActiveRecord::Base.connection.exec_query("
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
      WHERE tenants.id = #{args[:tenant_id]}
      AND   hubs.id IN #{hub_ids.sql_format}
      GROUP BY trucking_pricings.id
      ORDER BY MAX(trucking_destinations.zipcode), MAX(trucking_destinations.distance), MAX(trucking_destinations.city_name)
    ")

    result.map do |row|
      filter = parse_sql_array(row["filter"])
      {
        "truckingPricing"  => find(row["id"]),
        filter.first => filter[1..-1]
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
    raise ArgumentError, "Must provide load_type" if args[:load_type].nil?
    raise ArgumentError, "Must provide tenant_id" if args[:tenant_id].nil?
    raise ArgumentError, "Must provide carriage"  if args[:carriage].nil?
    if args.keys.size < 3
      raise ArgumentError, "Must provide a valid filter besides load_type, carriage and tenant_id"
    end
  end

  def self.truck_type_condition(args)
    args[:truck_type] ? "AND trucking_pricings.truck_type = '#{args[:truck_type]}'" : ""
  end

  def self.nexuses_condition(args)
    args[:nexus_ids] ? "AND locations.id IN #{args[:nexus_ids].sql_format}" : ""
  end

  def self.parse_sql_array(str)
    str.gsub(/\(|\)|\"/, "").split(",")
  end


end
