# frozen_string_literal: true

class FixBackfillDataIssuesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    invalid_route_points = Journey::RoutePoint.where(name: "deleted")
    invalid_route_sections = Journey::RouteSection.where(from: invalid_route_points).or(Journey::RouteSection.where(to: invalid_route_points))
    invalid_queries = Journey::Query.joins(result_sets: :results).where(journey_results: { id: invalid_route_sections.select(:result_id).distinct })
    invalid_queries.find_each.with_index do |query, index|
      at(index + 1)
      quotation = Quotations::Quotation.find_by(created_at: query.created_at, organization: query.organization)
      next unless quotation_needs_updating(quotation: quotation)

      ActiveRecord::Base.transaction do
        decorated_query = ResultFormatter::QueryDecorator.new(query)
        update_query(query: query, quotation: quotation) if [query.origin, query.destination].any? { |string| string == "deleted" }
        decorated_query.results.each do |result|
          next if skip_result?(result: result)

          update_freight(quotation: quotation, route_section: result.main_freight_section)
          update_pre_carriage(quotation: quotation, route_section: result.pre_carriage_section) if result.pre_carriage_section.present?
          update_origin_relay(quotation: quotation, route_section: result.origin_transfer_section) if result.origin_transfer_section.present?
          update_destination_relay(quotation: quotation, route_section: result.destination_transfer_section) if result.destination_transfer_section.present?
          update_on_carriage(quotation: quotation, route_section: result.on_carriage_section) if result.on_carriage_section.present?
        end
      end
    end
  end

  def update_query(query:, quotation:)
    if query.origin == "deleted"
      attr_key = query.has_pre_carriage? ? :pickup_address : :origin_nexus
      string, coords = extract_string_and_coordinates(quotation: quotation, target: attr_key)
      query.origin = string
      query.origin_coordinates = coords
    end
    if query.destination == "deleted"
      attr_key = query.has_on_carriage? ? :delivery_address : :destination_nexus
      string, coords = extract_string_and_coordinates(quotation: quotation, target: attr_key)
      query.destination = string
      query.destination_coordinates = coords
    end
    query.save!
  end

  def update_freight(route_section:, quotation:)
    update_nexus_route_point(route_point: route_section.from, quotation: quotation, target: :origin_nexus) if route_section.from.name == "deleted"
    update_nexus_route_point(route_point: route_section.to, quotation: quotation, target: :destination_nexus) if route_section.to.name == "deleted"
  end

  def update_pre_carriage(route_section:, quotation:)
    update_address_route_point(route_point: route_section.from, quotation: quotation, target: :pickup_address) if route_section.from.name == "deleted"
    update_nexus_route_point(route_point: route_section.to, quotation: quotation, target: :origin_nexus) if route_section.to.name == "deleted"
  end

  def update_on_carriage(route_section:, quotation:)
    update_nexus_route_point(route_point: route_section.from, quotation: quotation, target: :destination_nexus) if route_section.from.name == "deleted"
    update_address_route_point(route_point: route_section.to, quotation: quotation, target: :delivery_address) if route_section.to.name == "deleted"
  end

  def update_origin_relay(route_section:, quotation:)
    return if route_section.from.name != "deleted"

    update_nexus_route_point(route_point: route_section.from, quotation: quotation, target: :origin_nexus)
    update_nexus_route_point(route_point: route_section.to, quotation: quotation, target: :origin_nexus)
  end

  def update_destination_relay(quotation:, route_section:)
    return if route_section.from.name != "deleted"

    update_nexus_route_point(route_point: route_section.from, quotation: quotation, target: :destination_nexus)
    update_nexus_route_point(route_point: route_section.to, quotation: quotation, target: :destination_nexus)
  end

  def extract_string_and_coordinates(quotation:, target:)
    data = extract_target_data(quotation: quotation, target: target)
    return [] if data.blank?

    [data.name, RGeo::Geos.factory(srid: 4326).point(data.longitude, data.latitude)]
  end

  def extract_target_data(quotation:, target:)
    shipment = Legacy::Shipment.find_by(id: quotation.legacy_shipment_id)
    data = quotation.send(target) || shipment&.send(target)
    return data if data.present?

    return find_fallback_nexus_data(quotation: quotation, target: target) if target.to_s.include?("nexus")
  end

  def update_nexus_route_point(route_point:, quotation:, target:)
    nexus = extract_target_data(quotation: quotation, target: target)
    locode = locode_with_fallback(nexus: nexus)
    route_point.update(
      administrative_area: "",
      city: nexus.name,
      coordinates: RGeo::Geos.factory(srid: 4326).point(nexus.longitude, nexus.latitude),
      country: nexus.country.name,
      function: "nexus",
      locode: locode,
      name: nexus.name,
      geo_id: geo_id(query: locode)
    )
  end

  def update_address_route_point(route_point:, quotation:, target:)
    _string, coords = extract_string_and_coordinates(quotation: quotation, target: target)
    return fallback_address_route_point_update(route_point: route_point, quotation: quotation, target: target) if coords.blank?

    address = Legacy::Address.new(latitude: coords.y, longitude: coords.x).reverse_geocode
    route_point.update(
      administrative_area: "",
      city: address.city,
      coordinates: coords,
      country: address.country.name,
      function: "address",
      locode: nil,
      name: address.geocoded_address,
      postal_code: address.zip_code,
      street: address.street,
      street_number: address.street_number,
      geo_id: geo_id(query: address.geocoded_address)
    )
  end

  def fallback_address_route_point_update(route_point:, quotation:, target:)
    fallback_attr = target.to_s.include?("pickup") ? :origin_nexus : :destination_nexus
    nexus = extract_target_data(quotation: quotation, target: fallback_attr)

    route_point.update(
      administrative_area: "",
      city: nexus.name,
      coordinates: RGeo::Geos.factory(srid: 4326).point(nexus.longitude, nexus.latitude),
      country: nexus.country.name,
      function: "address",
      locode: nil,
      name: "#{nexus.name}, #{nexus.country.code}",
      geo_id: geo_id(query: nexus.locode) # Not sure where else to get geo_id
    )
  end

  def geo_id(query:)
    Carta::Client.suggest(query: query)&.id
  end

  def locode_with_fallback(nexus:)
    return nexus.locode if nexus.locode.present?

    other_nexus = Legacy::Nexus.where.not(locode: nil).find_by(country: nexus.country, name: nexus.name.strip)

    return other_nexus.locode if other_nexus&.locode.present?

    if nexus.name.include?("/")
      Legacy::Nexus.where.not(locode: nil).find_by(country: nexus.country, name: nexus.name.split("/").first.strip)&.locode
    elsif nexus.name.include?("'")
      Legacy::Nexus.where.not(locode: nil).where("name ILIKE ?", nexus.name.delete("'")).find_by(country: nexus.country)&.locode
    end
  end

  def find_fallback_nexus_data(quotation:, target:)
    tender = quotation.tenders.first
    string = tender.name.split(" - ")[target.to_s.include?("origin") ? 0 : 1]
    nexus = Legacy::Nexus.where.not(locode: nil).find_by(name: string)
    return nexus if nexus.present?

    ["CY", "Port", "Railyard", "Depot", "Airport", "Med", /\s*\(.+\)$/].each do |invalid_text|
      string.gsub!(invalid_text, "")
    end

    Legacy::Nexus.where.not(locode: nil).find_by(name: string.split("/").map(&:strip))
  end

  def quotation_needs_updating(quotation:)
    validity_data = validity_lookup[quotation.organization.slug]
    return false if validity_data.blank?

    validity_data["start"] < quotation.created_at && validity_data["end"] > quotation.created_at
  end

  def validity_lookup
    {
      "normanglobal" => { "start" => Date.parse("2019-02-01"), "end" =>	Date.parse("2020-02-01") },
      "7connetwork" => { "start" => Date.parse("2020-11-01"), "end" =>	Date.parse("2021-09-22") },
      "unsworth" => { "start" => Date.parse("2020-07-01"), "end" =>	Time.zone.tomorrow },
      "freightright" => { "start" => Date.parse("2019-12-01"), "end" =>	Date.parse("2020-12-01") },
      "shipfreightto" => { "start" => Date.parse("2020-01-01"), "end" =>	Date.parse("2021-01-01") },
      "fivestar" => { "start" => Date.parse("2019-02-01"), "end" =>	Time.zone.tomorrow },
      "fivestar-nl" => { "start" =>	Date.parse("2020-08-01"), "end" => Time.zone.tomorrow	},
      "fivestar-be" => { "start" =>	Date.parse("2020-08-01"), "end" =>	Time.zone.tomorrow },
      "berkman" => { "start" => Date.parse("2020-02-01"), "end" =>	Date.parse("2021-02-01") },
      "gateway" => { "start" => Date.parse("2019-02-01"), "end" =>	Time.zone.tomorrow },
      "ssc" => { "start" => Date.parse("2020-12-01"), "end" => Time.zone.tomorrow	},
      "saco" => { "start" => Date.parse("2020-02-17"), "end" =>	Time.zone.tomorrow },
      "racingcargo" => { "start" => Date.parse("2020-08-01"), "end" =>	Time.zone.tomorrow }
    }
  end

  def skip_result?(result:)
    Quotations::LineItem.where(tender_id: result.id).count.zero? || result.route_sections.count.zero?
  end
end
