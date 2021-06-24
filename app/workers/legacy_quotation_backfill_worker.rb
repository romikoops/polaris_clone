# frozen_string_literal: true

class LegacyQuotationBackfillWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  RoutingVerificationFailed = Class.new(StandardError)
  CargoVerificationFailed = Class.new(StandardError)
  LineItemVerificationFailed = Class.new(StandardError)

  def perform
    @failed_quotations = []
    organizations = Organizations::Organization.where(slug: validity_lookup.keys)
    org_count = organizations.count
    total org_count

    organizations.find_each.with_index do |organization, index|
      quotations = Legacy::Quotation.joins(:shipments)
        .where(billing: ["external", nil], shipments: { tender_id: nil, organization_id: organization.id })
        .where.not(created_at: Journey::Query.where(organization: organization).select(:created_at))
        .where("quotations.created_at > ? AND quotations.created_at < ?", validity_lookup[organization.slug]["start"], validity_lookup[organization.slug]["end"])

      at index + 1, "Organization #{index + 1}/#{org_count} (slug: #{organization.slug} #{quotations.count} Quotations to be backfilled"

      quotations.find_each do |quotation|
        shipment = quotation.shipments.first
        charge_breakdown = quotation.shipments.flat_map(&:charge_breakdowns).first
        next if shipment.nil? || charge_breakdown.nil? || quotation.shipments.any? { |ship| ship.status != "quoted" }

        @origin = origin_from_shipment(shipment: shipment)
        @destination = destination_from_shipment(shipment: shipment)

        next if @origin.blank? || @destination.blank?

        ActiveRecord::Base.transaction do
          user = Users::Client.global.find_by(id: quotation.user_id)
          cargo_ready_date = shipment.planned_pickup_date || shipment.planned_origin_drop_off_date || shipment.planned_etd || shipment.desired_start_date || shipment.booking_placed_at
          query = Journey::Query.new(
            client: user,
            creator: user,
            billable: shipment.billing != "test",
            load_type: shipment.load_type == "cargo_item" ? "lcl" : "fcl",
            company: Companies::Membership.find_by(member: user)&.company,
            cargo_ready_date: cargo_ready_date,
            delivery_date: [(shipment.planned_delivery_date || shipment.planned_destination_collection_date || shipment.planned_eta || cargo_ready_date), cargo_ready_date + 25.days].max,
            source_id: Doorkeeper::Application.find_by(name: "dipper").id,
            origin: shipment.pickup_address&.geocoded_address || @origin&.name,
            destination: shipment.delivery_address&.geocoded_address || @destination&.name,
            origin_coordinates: shipment.pickup_address&.geo_point || RGeo::Geos.factory(srid: 4326).point(@origin&.longitude, @origin&.latitude),
            destination_coordinates: shipment.delivery_address&.geo_point || RGeo::Geos.factory(srid: 4326).point(@destination&.longitude, @destination&.latitude),
            insurance: shipment.insurance.present?,
            customs: shipment.customs.present?,
            organization: shipment.organization,
            created_at: quotation.created_at,
            updated_at: quotation.updated_at
          )
          if !query.valid? && safe_to_ignore_validations(query: query)
            query.save!(validate: false)
          else
            query.save!
          end

          @cargo_map = build_cargo_map(quotation: quotation, query: query)
          create_result_set(query: query, charge_breakdown: charge_breakdown, quotation: quotation)

          verify_query(query: query, quotation: quotation)
        end
      end
    end
    send_status_email
  end

  def build_cargo_map(quotation:, query:)
    shipment = Legacy::Shipment.with_deleted.find_by(id: quotation.original_shipment_id) || quotation.shipments.first
    if shipment.aggregated_cargo.present?
      { shipment.aggregated_cargo.id => Journey::CargoUnit.create!(
        query: query,
        weight_value: shipment.aggregated_cargo.weight,
        volume_value: shipment.aggregated_cargo.volume,
        quantity: 1,
        stackable: true,
        cargo_class: "aggregated_lcl",
        created_at: shipment.aggregated_cargo.created_at,
        updated_at: shipment.aggregated_cargo.updated_at
      ) }
    else
      shipment.cargo_units.each_with_object({}) do |unit, result|
        result[unit.id] = Journey::CargoUnit.create!(
          query: query,
          weight_value: [unit.payload_in_kg, 0.01].max,
          width_value: unit.cargo_class == "lcl" ? [(unit.width / 100.0), 1e-3].max : nil,
          length_value: unit.cargo_class == "lcl" ? [(unit.length / 100.0), 1e-3].max : nil,
          height_value: unit.cargo_class == "lcl" ? [(unit.height / 100.0), 1e-3].max : nil,
          quantity: unit.quantity,
          stackable: unit.cargo_class == "lcl" ? unit.stackable : true,
          cargo_class: unit.cargo_class,
          colli_type: colli_type_from_cargo_item_type(unit: unit),
          commodity_infos: commodity_info_from_unit(unit: unit),
          created_at: unit.created_at,
          updated_at: unit.updated_at
        )
      end
    end
  end

  def colli_type_from_cargo_item_type(unit:)
    return "container" if unit.cargo_class != "lcl"

    case unit.cargo_item_type.category.downcase
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
    end
  end

  def create_result_set(query:, charge_breakdown:, quotation:)
    Journey::ResultSet.create!(
      query: query,
      status: "completed",
      currency: charge_breakdown.grand_total.price.currency,
      results: create_results(quotation: quotation),
      created_at: quotation.created_at,
      updated_at: quotation.updated_at
    )
  end

  def create_results(quotation:)
    quotation.shipments.map { |shipment| create_result(shipment: shipment) }
  end

  def create_result(shipment:)
    charge_breakdown = shipment.charge_breakdowns.selected
    route_sections_hash = route_sections_hash(charge_breakdown: charge_breakdown)
    trip = charge_breakdown.trip
    Journey::Result.new(
      expiration_date: charge_breakdown.valid_until || charge_breakdown.created_at + (trip&.end_date ? (trip.end_date - trip.start_date).to_i.seconds : 25.days),
      issued_at: charge_breakdown.created_at,
      route_sections: route_sections_hash.values.flatten,
      line_item_sets: line_item_sets(charge_breakdown: charge_breakdown, route_sections_hash: route_sections_hash),
      created_at: charge_breakdown.created_at,
      updated_at: charge_breakdown.updated_at
    )
  end

  def route_sections_hash(charge_breakdown:)
    charge_breakdown.charges.where(detail_level: 1).each_with_object({}) do |section_charge, hash|
      hash[section_charge] = route_section_from_shipment_and_section_charge(charge_breakdown: charge_breakdown, section_charge: section_charge)
    end
  end

  def route_section_from_shipment_and_section_charge(charge_breakdown:, section_charge:)
    shipment = charge_breakdown.shipment
    case section_charge.children_charge_category.code
    when "trucking_pre"
      Journey::RouteSection.new(
        from: route_point_from_address(address: shipment.pickup_address),
        to: route_point_from_nexus(nexus: @origin),
        service: charge_breakdown.pickup_tenant_vehicle&.name || "standard",
        carrier: charge_breakdown.pickup_tenant_vehicle&.carrier&.name || shipment.organization.slug.humanize,
        transit_time: 0,
        order: 0,
        mode_of_transport: "carriage",
        created_at: charge_breakdown.created_at,
        updated_at: charge_breakdown.updated_at
      )
    when "export"
      Journey::RouteSection.new(
        from: route_point_from_nexus(nexus: @origin),
        to: route_point_from_nexus(nexus: @origin),
        service: charge_breakdown.freight_tenant_vehicle&.name || "standard",
        carrier: shipment.organization.slug.humanize,
        transit_time: 0,
        order: 1,
        mode_of_transport: "relay",
        created_at: charge_breakdown.created_at,
        updated_at: charge_breakdown.updated_at
      )
    when "cargo"
      Journey::RouteSection.new(
        from: route_point_from_nexus(nexus: @origin),
        to: route_point_from_nexus(nexus: @destination),
        service: charge_breakdown.freight_tenant_vehicle&.name || "standard",
        carrier: charge_breakdown.freight_tenant_vehicle&.carrier&.name || shipment.organization.slug.humanize,
        transit_time: Legacy::TransitTime.find_by(itinerary: charge_breakdown.shipment.itinerary, tenant_vehicle: charge_breakdown.freight_tenant_vehicle)&.duration || 25,
        order: 2,
        mode_of_transport: shipment.mode_of_transport || (shipment.origin_hub || shipment.destination_hub)&.hub_type || "ocean",
        created_at: charge_breakdown.created_at,
        updated_at: charge_breakdown.updated_at
      )
    when "import"
      Journey::RouteSection.new(
        from: route_point_from_nexus(nexus: @destination),
        to: route_point_from_nexus(nexus: @destination),
        service: charge_breakdown.freight_tenant_vehicle&.name || "standard",
        carrier: charge_breakdown.freight_tenant_vehicle&.carrier&.name || shipment.organization.slug.humanize,
        transit_time: 0,
        order: 3,
        mode_of_transport: "relay",
        created_at: charge_breakdown.created_at,
        updated_at: charge_breakdown.updated_at
      )
    when "trucking_on"
      Journey::RouteSection.new(
        to: route_point_from_address(address: shipment.delivery_address),
        from: route_point_from_nexus(nexus: @destination),
        service: charge_breakdown.delivery_tenant_vehicle&.name || "standard",
        carrier: charge_breakdown.delivery_tenant_vehicle&.carrier&.name || shipment.organization.slug.humanize,
        transit_time: 0,
        order: 4,
        mode_of_transport: "carriage",
        created_at: charge_breakdown.created_at,
        updated_at: charge_breakdown.updated_at
      )
    end
  end

  def route_point_from_address(address:)
    address.geocoded_address = [address.zip_code, address.city, address.country.name].join(", ") if address.geocoded_address.blank?
    address.geocode if address.geo_point.blank?

    Journey::RoutePoint.create(
      name: address.geocoded_address,
      function: "carriage",
      coordinates: address.geo_point,
      postal_code: address.zip_code,
      city: address.city,
      street: address.street,
      street_number: address.street_number,
      administrative_area: "",
      country: address.country&.code || "unknown",
      geo_id: geo_id_from_address(address: address)
    )
  end

  def route_point_from_nexus(nexus:)
    Journey::RoutePoint.create(
      name: nexus.name,
      locode: nexus.locode,
      function: "port",
      coordinates: RGeo::Geos.factory(srid: 4326).point(nexus.longitude, nexus.latitude),
      geo_id: geo_id_from_nexus(nexus: nexus)
    )
  end

  def geo_id_from_address(address:)
    existing = Journey::RoutePoint.find_by(name: address.geocoded_address)
    return existing.id if existing.present?

    Carta::Client.suggest(query: address.geocoded_address)&.id
  rescue Carta::Client::LocationNotFound
    Carta::Client.reverse_geocode(latitude: address.latitude, longitude: address.longitude).id
  end

  def geo_id_from_nexus(nexus:)
    existing = Journey::RoutePoint.find_by(locode: nexus.locode)
    return existing.id if existing.present?

    Carta::Client.suggest(query: nexus.locode)&.id
  rescue Carta::Client::LocationNotFound
    Carta::Client.reverse_geocode(latitude: nexus.latitude, longitude: nexus.longitude).id
  end

  def line_item_sets(charge_breakdown:, route_sections_hash:)
    sets = [
      Journey::LineItemSet.new(
        line_items: line_items(charge_breakdown: charge_breakdown, route_sections_hash: route_sections_hash),
        reference: charge_breakdown.shipment.imc_reference,
        created_at: charge_breakdown.created_at
      )
    ]
    if charge_breakdown.charges.where.not(edited_price_id: nil).present?
      sets << Journey::LineItemSet.new(
        line_items: line_items(charge_breakdown: charge_breakdown, route_sections_hash: route_sections_hash, edited: true),
        reference: Journey::ImcReference.new(date: charge_breakdown.created_at + 1.minute),
        created_at: charge_breakdown.created_at + 1.minute
      )
    end
    sets
  end

  def line_items(charge_breakdown:, route_sections_hash:, edited: false)
    route_sections_hash.entries.flat_map do |section_charge, route_section|
      section_charge.children.flat_map(&:children).map do |charge|
        next if charge.children_charge_category.code == "total"

        price = edited ? (charge.edited_price || charge.price) : charge.price
        cargo = @cargo_map[charge.charge_category.cargo_unit_id]

        Journey::LineItem.new(
          route_section: route_section,
          route_point: route_section.from,
          total: price.money.round(BigDecimal::ROUND_HALF_UP, 0),
          unit_price: price.money / (cargo&.quantity || 1),
          units: (cargo&.quantity || 1),
          fee_code: charge.children_charge_category.code,
          chargeable_density: 1,
          order: route_section.order,
          description: charge.children_charge_category.name,
          included: charge.children_charge_category.code.include?("included"),
          optional: charge.children_charge_category.code.include?("unknown"),
          cargo_units: [cargo].compact,
          exchange_rate: exchange_rate(from: price.currency, to: charge_breakdown.grand_total.price.currency)
        )
      end
    end.compact
  end

  def exchange_rate(from:, to:)
    return 1 if from == to

    bank_for_backfill.get_rate(from, to)
  end

  def bank_for_backfill
    store = MoneyCache::Converter.new(
      klass: Treasury::ExchangeRate,
      date: DateTime.new(2020, 3, 5, 0, 0, 0),
      config: { bank_app_id: Settings.open_exchange_rate&.app_id || "" }
    )
    Money::Bank::VariableExchange.new(store)
  end

  def commodity_info_from_unit(unit:)
    return [] unless unit.dangerous_goods

    [
      Journey::CommodityInfo.new(description: "Unknown Dangerous Goods", imo_class: "0")
    ]
  end

  def verify_query(query:, quotation:)
    shipment = quotation.shipments.first
    origin = shipment.pickup_address&.geocoded_address || origin_from_shipment(shipment: shipment).name
    destination = shipment.delivery_address&.geocoded_address || destination_from_shipment(shipment: shipment).name
    register_error(quotation: quotation, message: "Query info did not copy correctly")
    raise RoutingVerificationFailed if query.origin != origin || query.destination != destination

    cargo_units_are_valid(quotation: quotation)
    quotation.shipments.each do |quoted_shipment|
      charge_breakdown = quoted_shipment.charge_breakdowns.selected
      verify_result(
        result: query.results.find_by(created_at: charge_breakdown.created_at),
        charge_breakdown: charge_breakdown
      )
    end
  end

  def verify_result(result:, charge_breakdown:)
    decorated_result = ::ResultFormatter::ResultDecorator.new(result)
    invalid_line_items = charge_breakdown.charges.where(detail_level: 3).reject do |charge|
      line_item_is_valid(charge: charge, result: decorated_result)
    end
    register_error(quotation: charge_breakdown.shipment.quotation, message: "Line Items did not copy correctly")
    raise LineItemVerificationFailed if invalid_line_items.any?(&:blank?)
  end

  def line_item_is_valid(charge:, result:)
    enum = charge.parent.charge_category.code
    return true if %w[customs insurance].include?(enum) || charge.children_charge_category.code == "total"

    result.line_item_sets.order(:created_at).map.with_index do |line_item_set, index|
      journey_line_item = line_item_set.line_items.find_by(
        fee_code: charge.children_charge_category.code,
        route_section: route_section_from_legacy_enum(result: result, enum: enum)
      )

      return false if journey_line_item.blank?

      amount = index.zero? ? charge.price.money : (charge.edited_price || charge.price).money
      journey_line_item.total == amount.round(BigDecimal::ROUND_HALF_UP, 0) && journey_line_item.description == charge.children_charge_category.name
    end
  end

  def route_section_from_legacy_enum(result:, enum:)
    case enum
    when /trucking_pre/
      result.pre_carriage_section
    when /trucking_on/
      result.on_carriage_section
    when /export/
      result.origin_transfer_section
    when /import/
      result.destination_transfer_section
    when /cargo/
      result.main_freight_section
    end
  end

  def cargo_units_are_valid(quotation:)
    shipment = Legacy::Shipment.with_deleted.find_by(id: quotation.original_shipment_id) || quotation.shipments.first
    cargo_is_valid = true
    if shipment.aggregated_cargo
      journey_cargo_unit = @cargo_map[shipment.aggregated_cargo.id]

      weight_matches = journey_cargo_unit.weight == Measured::Weight.new(shipment.aggregated_cargo.weight.round(5), "kg")
      volume_matches = journey_cargo_unit.volume == Measured::Volume.new(shipment.aggregated_cargo.volume, "m3")

      cargo_is_valid = false unless weight_matches && volume_matches
    else
      shipment.cargo_units.each do |unit|
        journey_cargo_unit = @cargo_map[unit.id]
        weight_matches = journey_cargo_unit.weight == Measured::Weight.new([unit.payload_in_kg, 0.01].max.round(5), "kg")
        next unless unit.cargo_class == "lcl"

        height_matches = journey_cargo_unit.height == Measured::Length.new(([(unit.height / 100.0), 1e-3].max).round(5), "m")
        length_matches = journey_cargo_unit.length == Measured::Length.new(([(unit.length / 100.0), 1e-3].max).round(5), "m")
        width_matches = journey_cargo_unit.width == Measured::Length.new(([(unit.width / 100.0), 1e-3].max).round(5), "m")
        colli_type_matches = unit.cargo_item_type.category.downcase.include?(journey_cargo_unit.colli_type)

        cargo_is_valid = false unless weight_matches && height_matches && length_matches && width_matches && colli_type_matches
      end
    end

    register_error(quotation: quotation, message: "Cargo Units did not copy correctly")
    raise CargoVerificationFailed unless cargo_is_valid
  end

  def origin_from_shipment(shipment:)
    nexus = (shipment.origin_nexus || shipment.origin_hub&.nexus || pdf_nexus_lookup[shipment.id])
    return nexus if nexus.present?

    if shipment.meta["trucking_pre_margin"]
      id = shipment.meta["trucking_pre_margin"].keys.first.split("UTC-").last
      nexus = Trucking::Trucking.find_by(id: id)&.hub&.nexus
    end

    return nexus if nexus.present?

    if shipment.meta["export_margin"]
      id = shipment.meta["export_margin"].keys.first.split("UTC-").last
      nexus = LocalCharge.find_by(id: id)&.hub&.nexus
    end
    return nexus if nexus.present?

    if shipment.meta["freight_margin"]
      id = shipment.meta["freight_margin"].keys.first.split("UTC-").last
      nexus = Pricings::Pricing.find_by(id: id)&.itinerary&.origin_hub&.nexus
    end
    nexus
  end

  def destination_from_shipment(shipment:)
    nexus = (shipment.destination_nexus || shipment.destination_hub&.nexus || pdf_nexus_lookup[shipment.id])
    return nexus if nexus.present?

    if shipment.meta["trucking_on_margin"]
      id = shipment.meta["trucking_on_margin"].keys.first.split("UTC-").last
      nexus = Trucking::Trucking.find_by(id: id)&.hub&.nexus
    end
    return nexus if nexus.present?

    if shipment.meta["import_margin"]
      id = shipment.meta["import_margin"].keys.first.split("UTC-").last
      nexus = LocalCharge.find_by(id: id)&.hub&.nexus
    end
    return nexus if nexus.present?

    if shipment.meta["freight_margin"]
      id = shipment.meta["freight_margin"].keys.first.split("UTC-").last
      nexus = Pricings::Pricing.find_by(id: id)&.itinerary&.destination_hub&.nexus
    end

    nexus
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
      "lclsaco" => { "start" => Date.parse("2020-08-16"), "end" =>	Time.zone.tomorrow },
      "racingcargo" => { "start" => Date.parse("2020-08-01"), "end" =>	Time.zone.tomorrow }
    }
  end

  def register_error(quotation:, message:)
    @failed_quotations << { reason: "Quotation #{quotation.id} failed with message: #{message}" }
  end

  def pdf_nexus_lookup
    {
      21_124 => Legacy::Nexus.find(32_660),
      23_693 => Legacy::Nexus.find(9931),
      21_485 => Legacy::Nexus.find(32_660),
      14_534 => Legacy::Nexus.find(9801),
      14_687 => Legacy::Nexus.find(9801), # All Fivestar ones are missing origin (only Hamburg)
      16_215 => Legacy::Nexus.find(9801),
      17_346 => Legacy::Nexus.find(9801),
      17_480 => Legacy::Nexus.find(9801)
    }
  end

  def safe_to_ignore_validations(query:)
    query_error_details = query.errors.details
    return false if query_error_details.keys.any? { |error_key| %i[cargo_ready_date delivery_date].exclude?(error_key) }

    cargo_ready_date_expected_error = !query_error_details[:cargo_ready_date] || query_error_details[:cargo_ready_date].all? { |error| error[:error] == :date_after_or_equal_to }
    delivery_date_expected_error = !query_error_details[:delivery_date] || query_error_details[:delivery_date].all? { |error| error[:error] == :date_after_or_equal_to }
    cargo_ready_date_expected_error && delivery_date_expected_error
  end

  def send_status_email
    result = { "has_errors" => @failed_quotations.present? }
    result.merge("errors" => @failed_quotations) if @failed_quotations.present?
    UploadMailer
      .with(
        user_id: Users::User.find_by(email: "shopadmin@itsmycargo.com").id,
        organization: Organizations::Organization.find_by(slug: "demo"),
        result: result,
        file: "LegacyQuotationBackfillWorker"
      )
      .complete_email
      .deliver_later
  end
end
