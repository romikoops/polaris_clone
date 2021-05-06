# frozen_string_literal: true

class BackfillShipmentsAndRequestsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    valid_statuses = %w[requested requested_by_unconfirmed_account in_progress confirmed finished]
    shipments = Legacy::Shipment.where(status: valid_statuses).where.not(created_at: Journey::Query.select(:created_at))
    total_quote_count = shipments.count
    total total_quote_count
    shipments.find_each.with_index do |shipment, index|
      at index + 1, "Shipment #{index + 1}/#{total_quote_count} (id: #{shipment.id}"
      ActiveRecord::Base.transaction do
        user = Users::Client.global.find_by(id: shipment.user_id)
        charge_breakdown = shipment.charge_breakdowns.selected
        cargo_ready_date = shipment.planned_pickup_date || shipment.planned_origin_drop_off_date || shipment.planned_etd || shipment.booking_placed_at
        delivery_date = shipment.planned_delivery_date || shipment.planned_destination_collection_date || shipment.planned_eta
        query = Journey::Query.new(
          client: user,
          creator: user,
          billable: shipment.billing != "test",
          load_type: shipment.load_type == "cargo_item" ? "lcl" : "fcl",
          company: Companies::Membership.find_by(member: user)&.company,
          cargo_ready_date: cargo_ready_date,
          delivery_date: [delivery_date, cargo_ready_date + 25.days].max,
          source_id: Doorkeeper::Application.find_by(name: "dipper").id,
          origin: shipment.pickup_address&.geocoded_address || shipment.origin_nexus&.name || "DELETED",
          destination: shipment.delivery_address&.geocoded_address || shipment.destination_nexus&.name || "DELETED",
          origin_coordinates: shipment.pickup_address&.geo_point || RGeo::Geos.factory(srid: 4326).point(shipment.origin_nexus&.longitude || 0, shipment.origin_nexus&.latitude || 0),
          destination_coordinates: shipment.delivery_address&.geo_point || RGeo::Geos.factory(srid: 4326).point(shipment.destination_nexus&.longitude || 0, shipment.destination_nexus&.latitude || 0),
          insurance: shipment.insurance.present?,
          customs: shipment.customs.present?,
          organization: shipment.organization,
          created_at: shipment.created_at,
          updated_at: shipment.updated_at
        )
        query.save!(validate: false)

        @cargo_map = cargo_map(shipment: shipment, query: query)
        create_result_set(query: query, charge_breakdown: charge_breakdown, shipment: shipment)
      end
    end
  end

  def cargo_map(shipment:, query:)
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
          weight_value: unit.payload_in_kg,
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

    case unit.cargo_item_type.category
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

  def create_result_set(query:, charge_breakdown:, shipment:)
    Journey::ResultSet.create(
      query: query,
      status: "completed",
      currency: charge_breakdown.grand_total.price.currency,
      results: create_results(shipment: shipment),
      created_at: shipment.created_at,
      updated_at: shipment.updated_at
    )
  end

  def create_results(shipment:)
    shipment.charge_breakdowns.map { |charge_breakdown| create_result(charge_breakdown: charge_breakdown) }
  end

  def create_result(charge_breakdown:)
    route_sections_hash = route_sections_hash(charge_breakdown: charge_breakdown)
    Journey::Result.new(
      expiration_date: charge_breakdown.valid_until,
      issued_at: charge_breakdown.created_at,
      route_sections: route_sections_hash.values.flatten,
      line_item_sets: line_item_sets(charge_breakdown: charge_breakdown, route_sections_hash: route_sections_hash),
      created_at: charge_breakdown.created_at,
      updated_at: charge_breakdown.updated_at,
      shipment_requests: [charge_breakdown.trip_id == charge_breakdown.shipment.trip_id ? create_shipment_request(shipment: charge_breakdown.shipment) : nil].compact
    )
  end

  def route_sections_hash(charge_breakdown:)
    charge_breakdown.charges.where(detail_level: 1, children_charge_category: valid_charge_categories(shipment: charge_breakdown.shipment)).each_with_object({}) do |section_charge, hash|
      hash[section_charge] = route_section_from_shipment_and_section_charge(charge_breakdown: charge_breakdown, section_charge: section_charge)
    end
  end

  def route_section_from_shipment_and_section_charge(charge_breakdown:, section_charge:)
    shipment = charge_breakdown.shipment
    case section_charge.children_charge_category.code
    when "trucking_pre"
      Journey::RouteSection.new(
        from: route_point_from_address(address: shipment.pickup_address),
        to: route_point_from_nexus(nexus: shipment.origin_nexus || shipment.origin_hub&.nexus),
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
        from: route_point_from_nexus(nexus: shipment.origin_nexus || shipment.origin_hub&.nexus),
        to: route_point_from_nexus(nexus: shipment.origin_nexus || shipment.origin_hub&.nexus),
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
        from: route_point_from_nexus(nexus: shipment.origin_nexus || shipment.origin_hub&.nexus),
        to: route_point_from_nexus(nexus: shipment.destination_nexus || shipment.destination_hub&.nexus),
        service: "standard",
        carrier: shipment.organization.slug.humanize,
        transit_time: Legacy::TransitTime.find_by(itinerary: charge_breakdown.shipment.itinerary, tenant_vehicle: charge_breakdown.freight_tenant_vehicle)&.duration || 25,
        order: 2,
        mode_of_transport: shipment.mode_of_transport,
        created_at: charge_breakdown.created_at,
        updated_at: charge_breakdown.updated_at
      )
    when "import"
      Journey::RouteSection.new(
        from: route_point_from_nexus(nexus: shipment.destination_nexus || shipment.destination_hub&.nexus),
        to: route_point_from_nexus(nexus: shipment.destination_nexus || shipment.destination_hub&.nexus),
        service: charge_breakdown.freight_tenant_vehicle&.name || "standard",
        carrier: shipment.organization.slug.humanize,
        transit_time: 0,
        order: 3,
        mode_of_transport: "relay",
        created_at: charge_breakdown.created_at,
        updated_at: charge_breakdown.updated_at
      )
    when "trucking_on"
      Journey::RouteSection.new(
        to: route_point_from_address(address: shipment.delivery_address),
        from: route_point_from_nexus(nexus: shipment.destination_nexus),
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
    address = address_or_fallback(address: address)
    existing = Journey::RoutePoint.find_by(name: address.geocoded_address)
    Journey::RoutePoint.create(
      name: address.geocoded_address,
      function: "carriage",
      coordinates: address.geo_point || deleted_address.point,
      postal_code: address.zip_code,
      city: address.city,
      street: address.street,
      street_number: address.street_number,
      administrative_area: "",
      country: address.country&.code || "unknown",
      geo_id: existing&.geo_id || "itsmycargo:BACKFILL-#{SecureRandom.uuid}"
    )
  end

  def route_point_from_nexus(nexus:)
    nexus ||= deleted_nexus
    existing = Journey::RoutePoint.find_by(locode: nexus.locode)

    Journey::RoutePoint.create(
      name: nexus.name,
      locode: nexus.locode,
      function: "port",
      coordinates: RGeo::Geos.factory(srid: 4326).point(nexus.longitude, nexus.latitude),
      geo_id: existing&.geo_id || "itsmycargo:BACKFILL-#{SecureRandom.uuid}"
    )
  end

  def line_item_sets(charge_breakdown:, route_sections_hash:)
    sets = [
      Journey::LineItemSet.new(line_items: line_items(charge_breakdown: charge_breakdown, route_sections_hash: route_sections_hash), created_at: charge_breakdown.created_at)
    ]
    sets << Journey::LineItemSet.new(line_items: line_items(charge_breakdown: charge_breakdown, route_sections_hash: route_sections_hash, edited: true), created_at: charge_breakdown.created_at) if charge_breakdown.charges.where.not(edited_price_id: nil).present?
    sets
  end

  def line_items(charge_breakdown:, route_sections_hash:, edited: false)
    route_sections_hash.entries.flat_map do |section_charge, route_section|
      section_charge.children.flat_map(&:children).map do |charge|
        price = edited ? charge.edited_price || charge.price : charge.price
        cargo = @cargo_map[charge.charge_category.cargo_unit_id]

        Journey::LineItem.new(
          route_section: route_section,
          route_point: route_section.from,
          total: price.money,
          unit_price: price.money / (cargo&.quantity || 1),
          units: (cargo&.quantity || 1),
          fee_code: charge.children_charge_category.code,
          wm_rate: 1,
          order: route_section.order,
          description: charge.children_charge_category.name,
          included: charge.children_charge_category.code.include?("included"),
          optional: charge.children_charge_category.code.include?("unknown"),
          cargo_units: [cargo].compact,
          exchange_rate: exchange_rate(from: price.currency, to: charge_breakdown.grand_total.price.currency)
        )
      end
    end
  end

  def exchange_rate(from:, to:)
    return 1 if from == to

    bank_for_backfill.get_rate(from, to)
  end

  def bank_for_backfill
    store = MoneyCache::Converter.new(
      klass: Treasury::ExchangeRate,
      date: DateTime.new(2020, 0o3, 0o5, 0, 0, 0),
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

  def deleted_nexus
    Legacy::Nexus.new(
      name: "deleted",
      locode: "deleted",
      longitude: 0,
      latitude: 0
    )
  end

  def deleted_address
    Legacy::Address.new(
      geocoded_address: "deleted",
      point: RGeo::Geos.factory(srid: 4326).point(0, 0),
      country: Legacy::Country.new(code: "00")
    )
  end

  def create_shipment_request(shipment:)
    Journey::ShipmentRequest.new(
      company: Companies::Membership.where(member_id: shipment.user_id).first&.company,
      client_id: shipment.user_id,
      contacts: create_contacts(shipment: shipment).compact,
      shipment: create_shipment(shipment: shipment)
    )
  end

  def create_contacts(shipment:)
    shipment.shipment_contacts.map do |shipment_contact|
      contact = shipment_contact.contact
      next if contact.blank?

      address = address_or_fallback(address: contact.address)

      Journey::Contact.new(
        company_name: contact.company_name,
        name: [contact.first_name, contact.last_name].join(" "),
        phone: contact.phone,
        address_line_1: address.geocoded_address,
        postal_code: address.zip_code,
        country_code: address.country.code,
        email: contact.email,
        city: address.city,
        original: find_or_create_original_contact(contact: contact, shipment: shipment)
      )
    end
  end

  def address_or_fallback(address:)
    return deleted_address if address.country.nil? && address.point.nil?

    address.reverse_geocode if address.country.nil? && address.point.present?
    address
  end

  def create_shipment(shipment:)
    Journey::Shipment.new(creator_id: shipment.user_id) if %w[in_progress confirmed finished].include?(shipment.status)
  end

  def find_or_create_original_contact(contact:, shipment:)
    address = address_or_fallback(address: contact.address)
    AddressBook::Contact.create_with(
      company_name: contact.company_name,
      geocoded_address: address.geocoded_address,
      point: address.point,
      premise: address.premise,
      province: address.province,
      street: address.street,
      street_number: address.street_number,
      postal_code: address.zip_code,
      country_code: address.country.code,
      city: address.city
    ).find_or_initialize_by(
      user_id: shipment.user_id,
      first_name: contact.first_name,
      last_name: contact.last_name,
      email: contact.email,
      phone: contact.phone
    )
  end

  def valid_charge_categories(shipment:)
    Legacy::ChargeCategory.where(code: %w[trucking_pre export cargo import trucking_on], organization: shipment.organization)
  end
end
