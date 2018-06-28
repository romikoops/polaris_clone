# frozen_string_literal: true

Dir["#{Rails.root}/app/queries/trucking_pricing/*.rb"].each { |file| require file }

class TruckingPricing < ApplicationRecord
  has_many :shipments
  belongs_to :trucking_pricing_scope
  delegate :courier, to: :trucking_pricing_scope
  belongs_to :tenant
  has_many :hub_truckings, dependent: :destroy
  has_many :hubs, through: :hub_truckings
  has_many :trucking_destinations, through: :hub_truckings
  extend MongoTools
  include Queries::TruckingPricing

  SCOPING_ATTRIBUTE_NAMES = %i(load_type cargo_class carriage courier_id truck_type).freeze

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
      next unless hub.tenant_id != t.id
      new_hub = Hub.find_by(name: hub.name, tenant_id: t.id)
      tp.hub_truckings.each do |ht|
        ht.hub_id = new_hub.id
        ht.save!
      end
    end
  end

  def self.delete_existing_truckings(hub)
    hub.trucking_pricings.delete_all
    hub.hub_truckings.delete_all  
  end

  def self.find_by_filter(args={})
    FindByFilter.new(args.merge(klass: self)).perform
  end

  def self.find_by_hub_id(hub_id)
    find_by_hub_ids([hub_id])
  end

  def self.find_by_hub_ids(hub_ids=[])
    raise ArgumentError, "Must provide hub_ids or hub_id" if hub_ids.empty?
    sanitized_query = sanitize_sql(["
      SELECT
        trucking_pricing_id,
        MIN(country_code) AS country_code,
        MIN(ident_type) AS ident_type,
        STRING_AGG(ident_values, ',') AS ident_values
      FROM (
        SELECT
          tp_id AS trucking_pricing_id,
          MIN(country_code) AS country_code,
          ident_type,
          CASE
            WHEN ident_type = 'city'
              THEN MIN(geometries.name_4) || '*' || MIN(geometries.name_2)
            ELSE
              MIN(ident_value)::text      || '*' || MAX(ident_value)::text
          END AS ident_values
        FROM (
          SELECT tp_id, ident_type, ident_value, country_code,
            CASE
            WHEN ident_type <> 'city'
              THEN DENSE_RANK() OVER(PARTITION BY tp_id, ident_type ORDER BY ident_value) - ident_value::integer
            END AS range
          FROM (
            SELECT
              trucking_pricings.id AS tp_id,
              trucking_destinations.country_code,
              CASE
                WHEN trucking_destinations.zipcode  IS NOT NULL THEN 'zipcode'
                WHEN trucking_destinations.distance IS NOT NULL THEN 'distance'
                ELSE 'city'
              END AS ident_type,
              CASE
                WHEN trucking_destinations.zipcode  IS NOT NULL THEN trucking_destinations.zipcode::integer
                WHEN trucking_destinations.distance IS NOT NULL THEN trucking_destinations.distance::integer
                ELSE trucking_destinations.geometry_id
              END AS ident_value
            FROM trucking_pricings
            JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
            JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
            WHERE hub_truckings.hub_id IN (:hub_ids)
          ) AS sub_query_lvl_3
        ) AS sub_query_lvl_2
        LEFT OUTER JOIN geometries ON sub_query_lvl_2.ident_value = geometries.id
        GROUP BY tp_id, ident_type, range
        ORDER BY MAX(ident_value)
      ) AS sub_query_lvl_1
      GROUP BY trucking_pricing_id
      ORDER BY ident_values
    ", hub_ids: hub_ids])

    connection.exec_query(sanitized_query).map do |row|
      {
        "truckingPricing" => find(row["trucking_pricing_id"]),
        row["ident_type"] => row["ident_values"].split(",").map { |range| range.split("*") },
        "countryCode"     => row["country_code"]
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
      WHERE trucking_pricings.id = #{id}
      LIMIT 1
    ").values.first.try(:first)
  end

  def hub_id
    ActiveRecord::Base.connection.execute("
      SELECT hubs.id FROM hubs
      JOIN hub_truckings ON hub_truckings.hub_id = hubs.id
      JOIN trucking_pricings ON hub_truckings.trucking_pricing_id = trucking_pricings.id
      WHERE trucking_pricings.id = #{id}
      LIMIT 1
    ").values.first.try(:first)
  end

  private

  def self.parse_sql_record(str)
    str.gsub(/\(|\)|\"/, "").split(",")
  end
end
