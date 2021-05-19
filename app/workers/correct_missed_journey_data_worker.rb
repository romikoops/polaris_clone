# frozen_string_literal: true

class CorrectMissedJourneyDataWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    Organizations::Organization.where(slug: validity_lookup.keys).find_each.with_index do |organization, index|
      at(index + 1)
      validity_data = validity_lookup[organization.slug]
      Quotations::Tender.joins(:line_items)
        .where(
          id: Journey::Result.joins(:query).where(journey_queries: { organization_id: organization.id }).ids,
          quotations_line_items: { section: nil }
        )
        .where("quotations_tenders.created_at > ? AND quotations_tenders.created_at < ?", validity_data["start"], validity_data["end"])
        .find_each do |tender|
        result = Journey::Result.find_by(id: tender.id)
        next unless needs_fixing?(tender: tender, result: result)

        @bank_for_query = bank_for_date(date: tender.created_at)
        ActiveRecord::Base.transaction do
          @cargo_lookup = build_cargo_lookup(quotation: tender.quotation, query: result.query)
          from, to = route_points_from_query(query: result.query)
          route_section = Journey::RouteSection.create!(
            result: result,
            transit_time: 25,
            mode_of_transport: mode_of_transport_from(tender: tender),
            service: tender.tenant_vehicle&.name || "standard",
            carrier: tender.tenant_vehicle&.carrier&.name || tender.quotation.organization.slug,
            from: from,
            to: to,
            order: 1
          )
          Journey::LineItemSet.create!(
            result: result,
            line_items: line_items(tender: tender, route_section: route_section, edited: false)
          )
          next unless tender.line_items.any? { |line_item| line_item.original_amount_cents != line_item.amount_cents }

          Journey::LineItemSet.create!(
            result: result,
            line_items: line_items(tender: tender, route_section: route_section, edited: true)
          )
        end
      end
    end
  end

  def line_items(tender:, route_section:, edited:)
    tender.line_items.map.with_index do |line_item, index|
      total = edited ? line_item.original_amount : line_item.amount
      cargo = @cargo_lookup[line_item.cargo_id]
      Journey::LineItem.new(
        fee_code: line_item.code,
        total: total,
        unit_price: total / (cargo&.quantity || 1),
        units: (cargo&.quantity || 1),
        chargeable_density: 1,
        exchange_rate: exchange_rate(from: line_item.amount_currency, to: route_section.result.result_set.currency),
        route_section: route_section,
        cargo_units: [cargo].compact,
        order: index
      )
    end
  end

  def route_points_from_query(query:)
    [
      route_point_from_string_and_coords(string: query.origin, coords: query.origin_coordinates),
      route_point_from_string_and_coords(string: query.destination, coords: query.destination_coordinates)
    ]
  end

  def route_point_from_string_and_coords(string:, coords:)
    nexus = Legacy::Nexus.where.not(locode: nil).find_by(name: string)
    return nexus_route_point(nexus: nexus) if nexus

    address_route_point(string: string, coords: coords)
  end

  def nexus_route_point(nexus:)
    Journey::RoutePoint.new(
      administrative_area: "",
      city: nexus.name,
      coordinates: RGeo::Geos.factory(srid: 4326).point(nexus.longitude, nexus.latitude),
      country: nexus.country.name,
      function: "nexus",
      locode: nexus.locode,
      name: nexus.name,
      geo_id: geo_id(query: nexus.locode)
    )
  end

  def address_route_point(string:, coords:)
    address = Legacy::Address.new(latitude: coords.y, longitude: coords.x).reverse_geocode
    Journey::RoutePoint.new(
      administrative_area: "",
      city: address.city,
      coordinates: coords,
      country: address.country.name,
      function: "address",
      locode: nil,
      name: string,
      postal_code: address.zip_code,
      street: address.street,
      street_number: address.street_number,
      geo_id: geo_id(query: string, fallback: address.geocoded_address)
    )
  end

  def geo_id(query:, fallback: nil)
    Carta::Client.suggest(query: query)&.id
  rescue Carta::Client::LocationNotFound
    return geo_id(query: fallback, fallback: nil) if fallback.present?

    "itsmycargo:BACKFILL-#{SecureRandom.uuid}" # Postal locations sourced fom our Locations::Name table dont find anything in Carta
  end

  def needs_fixing?(tender:, result:)
    missing_sections?(result: result) && incorrect_sections?(tender: tender, result: result)
  end

  def incorrect_sections?(tender:, result:)
    line_item_sections = tender.line_items.pluck(:section).uniq
    return false if line_item_sections.empty? && result.route_sections.empty?

    line_item_sections.count != result.route_sections.count
  end

  def missing_sections?(result:)
    !result.route_sections.exists?(mode_of_transport: %i[ocean air rail truck])
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

  def mode_of_transport_from(tender:)
    return "ocean" unless tender

    tender.itinerary&.mode_of_transport || tender.tenant_vehicle&.mode_of_transport || "ocean"
  end

  def build_cargo_lookup(quotation:, query:)
    return {} unless query.cargo_units.empty? && quotation.cargo.present?

    quotation.cargo.units.each_with_object({}) do |unit, result|
      result[unit.legacy_id] = Journey::CargoUnit.create!(
        query: query,
        weight: unit.weight,
        width: [unit.width, 1e-3].max,
        length: [unit.length, 1e-3].max,
        height: [unit.height, 1e-3].max,
        quantity: unit.quantity,
        stackable: unit.stackable,
        cargo_class: unit.cargo_class,
        colli_type: colli_type_from_cargo_item_type(unit: unit),
        commodity_infos: commodity_info_from_unit(unit: unit),
        created_at: unit.created_at,
        updated_at: unit.updated_at
      )
    end
  end

  def colli_type_from_cargo_item_type(unit:)
    return "container" if unit.lcl?
    return "pallet" if unit.legacy.nil?

    case unit.legacy.cargo_item_type.category.downcase
    when /barrel/
      "barrel"
    when /bottle/
      "bottle"
    when /carton/
      "carton"
    when /case/
      "case"
    when /crate/
      "crate"
    when /drum/
      "drum"
    when /package/
      "package"
    when /pallet/
      "pallet"
    when /roll/
      "roll"
    when /skid/
      "skid"
    when /stack/
      "stack"
    when /room_temp_reefer/
      "room_temp_reefer"
    when /low_temp_reefe/
      "low_temp_reefer"
    end
  end

  def commodity_info_from_unit(unit:)
    return [] unless unit.dangerous_goods

    [
      Journey::CommodityInfo.new(description: "Unknown Dangerous Goods", imo_class: "0")
    ]
  end

  def exchange_rate(from:, to:)
    return 1 if from == to

    @bank_for_query.get_rate(from, to)
  end

  def bank_for_date(date:)
    store = MoneyCache::Converter.new(
      klass: Treasury::ExchangeRate,
      date: [date, DateTime.new(2020, 0o3, 0o5, 0, 0, 0)].max,
      config: { bank_app_id: Settings.open_exchange_rate&.app_id || "" }
    )
    Money::Bank::VariableExchange.new(store)
  end
end
