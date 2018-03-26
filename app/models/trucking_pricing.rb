class TruckingPricing < ApplicationRecord
  has_many :shipments
  belongs_to :courier
  has_many :hub_truckings, dependent: :destroy
  has_many :hubs, through: :hub_truckings
  has_many :trucking_destinations, through: :hub_truckings
  extend MongoTools
  # Validations

  # Class methods
  def self.update_data
    TruckingPricing.all.each do |tp|
      # tp.load_type = tp.load_type == 'fcl' ? 'container' : 'cargo_item'
      # tp.truck_type =  "default" if tp.load_type != 'container'
      tp.truck_type = "side_lifter" if tp.truck_type == "sima"

      tp.save!
    end
  end

  def self.find_by_filter(args = {})
    find_by_filter_argument_errors(args)

    latitude  = args[:latitude]  || args[:location].try(:latitude)  || 0
    longitude = args[:longitude] || args[:location].try(:longitude) || 0
    zipcode   = args[:zipcode]   || args[:location].try(:get_zip_code)
    city_name = args[:city_name] || args[:location].try(:city)

    ids = ActiveRecord::Base.connection.execute("
      SELECT trucking_pricings.id FROM trucking_pricings
      JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
      JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
      JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
      JOIN  locations             ON hubs.location_id                      = locations.id
      JOIN  tenants               ON hubs.tenant_id                        = tenants.id
      WHERE tenants.id = #{args[:tenant_id]}
      AND trucking_pricings.load_type = '#{args[:load_type]}'
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
                ST_Point(locations.longitude, locations.latitude)::geography,
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

  private

  def self.find_by_filter_argument_errors(args)
    raise ArgumentError, "Must provide load_type" if args[:load_type].nil?
    raise ArgumentError, "Must provide tenant_id" if args[:tenant_id].nil?
    if args.keys.size < 3
      raise ArgumentError, "Must provide a valid filter besides load_type and tenant_id"
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
