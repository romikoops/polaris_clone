# frozen_string_literal: true

require 'bigdecimal'
require 'net/http'

module ShippingTools # rubocop:disable Metrics/ModuleLength
  include PricingTools
  include NotificationTools
  extend PricingTools
  extend NotificationTools
  InternalError = Class.new(StandardError)

  def self.create_shipments_from_quotation(shipment, results)
    main_quote = ShippingTools.handle_existing_quote(shipment, results)
    results.each do |result|
      next unless main_quote.shipments.where(trip_id: result['meta']['charge_trip_id']).empty?

      ShippingTools.create_shipment_from_result(main_quote: main_quote, original_shipment: shipment, result: result)
    end
    main_quote.shipments.map(&:reload)
    main_quote
  end

  def self.handle_existing_quote(shipment, results)
    existing_quote = Quotation.find_by(user_id: shipment.user_id, original_shipment_id: shipment.id)
    trip_ids = results.map { |r| r['meta']['charge_trip_id'] }
    if existing_quote && shipment.updated_at < existing_quote.updated_at
      main_quote = existing_quote
      main_quote.shipments.where.not(trip_id: trip_ids).destroy_all
    elsif existing_quote && shipment.updated_at > existing_quote.updated_at
      main_quote = existing_quote
      main_quote.shipments.destroy_all
    elsif !existing_quote
      main_quote = Quotation.create(user_id: shipment.user_id, original_shipment_id: shipment.id)
    end

    main_quote
  end

  def self.create_shipment(details, current_user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    tenant = current_user.tenant
    load_type = details['loadType'].underscore
    direction = details['direction']
    shipment = Shipment.new(
      user_id: current_user.id,
      status: 'booking_process_started',
      load_type: load_type,
      direction: direction,
      tenant_id: tenant.id
    )
    shipment.save!

    if tenant.scope['closed_quotation_tool']
      raise ApplicationError::NonAgentUser if current_user.agency.nil?

      user_pricing_id = current_user.agency.agency_manager_id
      itinerary_ids = current_user.tenant.itineraries.ids.reject do |id|
        Pricing.where(itinerary_id: id, user_id: user_pricing_id).for_load_type(load_type).empty?
      end
    else
      itinerary_ids = current_user.tenant.itineraries.ids.reject do |id|
        Pricing.where(itinerary_id: id).for_load_type(load_type).empty?
      end
    end

    routes_data = Route.detailed_hashes_from_itinerary_ids(
      itinerary_ids,
      with_truck_types: { load_type: load_type }
    )

    {
      shipment: shipment,
      routes: routes_data[:route_hashes],
      lookup_tables_for_routes: routes_data[:look_ups],
      cargo_item_types: tenant.cargo_item_types,
      max_dimensions: tenant.max_dimensions,
      max_aggregate_dimensions: tenant.max_aggregate_dimensions,
      last_available_date: Date.today
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def self.get_offers(params, current_user)
    shipment = Shipment.find(params[:shipment_id])
    offer_calculator = OfferCalculator.new(shipment, params, current_user)

    offer_calculator.perform
    offer_calculator.shipment.save!
    cargo_units = if offer_calculator.shipment.lcl? && !offer_calculator.shipment.aggregated_cargo
                    offer_calculator.shipment.cargo_units.map(&:with_cargo_type)
                  elsif offer_calculator.shipment.lcl? && offer_calculator.shipment.aggregated_cargo
                    [offer_calculator.shipment.aggregated_cargo]
                  else
                    offer_calculator.shipment.cargo_units
                  end

    if current_user.tenant.quotation_tool? && current_user.tenant.scope['email_all_quotes']
      quote = ShippingTools.create_shipments_from_quotation(
        offer_calculator.shipment,
        offer_calculator.detailed_schedules.map(&:deep_stringify_keys!)
      )
      QuoteMailer.quotation_admin_email(quote).deliver_later
    end

    {
      shipment: offer_calculator.shipment,
      results: offer_calculator.detailed_schedules,
      originHubs: offer_calculator.hubs[:origin],
      destinationHubs: offer_calculator.hubs[:destination],
      cargoUnits: cargo_units,
      aggregatedCargo: offer_calculator.shipment.aggregated_cargo
    }
  rescue ArgumentError
    raise ApplicationError::InternalError
  end

  def self.generate_shipment_pdf(shipment:)
    cargo_count = shipment.cargo_units.count
    load_type = ''
    if shipment.load_type == 'cargo_item' && cargo_count > 1
      load_type = 'Cargo Items'
    elsif shipment.load_type == 'cargo_item' && cargo_count == 1
      load_type = 'Cargo Item'
    elsif shipment.load_type == 'container' && cargo_count > 1
      load_type = 'Containers'
    elsif shipment.load_type == 'container' && cargo_count == 1
      load_type = 'Container'
    end

    shipment_recap = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      template: 'shipments/pdfs/shipment_recap.pdf.html.erb',
      margin: { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: shipment,
      shipments: [shipment],
      load_type: load_type,
      name: 'shipment_recap',
      remarks: Remark.where(tenant_id: shipment.tenant_id).order(order: :asc)
    )

    shipment_recap.generate
  end

  def self.update_shipment(params, current_user)
    tenant = current_user.tenant
    shipment = Shipment.find(params[:shipment_id])
    shipment_data = params[:shipment]

    hsCodes = shipment_data[:hsCodes].as_json
    hsTexts = shipment_data[:hsTexts].as_json
    shipment.assign_attributes(
      total_goods_value: shipment_data[:totalGoodsValue],
      cargo_notes: shipment_data[:cargoNotes]
    )
    shipment.incoterm_text = shipment_data[:incotermText] if shipment_data[:incotermText]

    # Shipper
    resource = shipment_data.require(:shipper)
    contact_address = Address.create_and_geocode(contact_address_params(resource))
    contact_params = contact_params(resource, contact_address.id)
    contact = search_contacts(contact_params, current_user)
    shipment.shipment_contacts.find_or_create_by(contact_id: contact.id, contact_type: 'shipper')
    shipper = { data: contact, address: contact_address.to_custom_hash }
    # NOT CORRECT:UserAddress.create(user: current_user, address: contact_address) if shipment.export?

    # Consignee
    resource = shipment_data.require(:consignee)
    contact_address = Address.create_and_geocode(contact_address_params(resource))
    contact_params = contact_params(resource, contact_address.id)
    contact = search_contacts(contact_params, current_user)
    shipment.shipment_contacts.find_or_create_by!(contact_id: contact.id, contact_type: 'consignee')
    consignee = { data: contact, address: contact_address.to_custom_hash }
    # NOT CORRECT:UserAddress.create(user: current_user, address: contact_address) if shipment.import?

    # Notifyees
    notifyees = shipment_data[:notifyees].try(:map) do |resource|
      contact_params = contact_params(resource, nil)
      contact = search_contacts(contact_params, current_user)
      shipment.shipment_contacts.find_or_create_by!(contact_id: contact.id, contact_type: 'notifyee')
      contact
    end || []

    charge_breakdown = shipment.charge_breakdowns.selected
    existing_insurance_charge = charge_breakdown.charge('insurance')
    existing_insurance_charge&.destroy
    existing_customs_charge = charge_breakdown.charge('customs')
    existing_customs_charge&.destroy
    # TBD - Adjust for itinerary logic
    if shipment_data[:insurance][:bool]
      @insurance_charge = Charge.create(
        children_charge_category: ChargeCategory.from_code('insurance', shipment.tenant_id),
        charge_category: ChargeCategory.grand_total,
        charge_breakdown: charge_breakdown,
        price: Price.create(currency: shipment.user.currency, value: shipment_data[:insurance][:value]),
        parent: charge_breakdown.charge('grand_total')
      )
    end
    if shipment_data[:customs][:total][:val].to_d.positive? || shipment_data[:customs][:total][:hasUnknown]
      @customs_charge = Charge.create(
        children_charge_category: ChargeCategory.from_code('customs', shipment.tenant_id),
        charge_category: ChargeCategory.grand_total,
        charge_breakdown: charge_breakdown,
        price: Price.create(
          currency: shipment_data[:customs][:total][:currency],
          value: shipment_data[:customs][:total][:val]
        ),
        parent: charge_breakdown.charge('grand_total')
      )
      if shipment_data[:customs][:import][:bool]
        @import_customs_charge = Charge.create(
          children_charge_category: ChargeCategory.from_code('import_customs', shipment.tenant_id),
          charge_category: ChargeCategory.grand_total,
          charge_breakdown: charge_breakdown,
          price: Price.create(
            currency: shipment_data[:customs][:import][:currency],
            value: shipment_data[:customs][:import][:val]
          ),
          parent: @customs_charge
        )
      end
      if shipment_data[:customs][:export][:bool]
        @export_customs_charge = Charge.create(
          children_charge_category: ChargeCategory.from_code('export_customs', shipment.tenant_id),
          charge_category: ChargeCategory.grand_total,
          charge_breakdown: charge_breakdown,
          price: Price.create(
            currency: shipment_data[:customs][:total][:currency],
            value: shipment_data[:customs][:export][:val]
          ),
          parent: @customs_charge
        )
      end

      @customs_charge.update_price!
    end
    if shipment_data[:addons][:customs_export_paper]
      @addons_charge = Charge.create(
        children_charge_category: ChargeCategory.from_code('addons', shipment.tenant_id),
        charge_category: ChargeCategory.grand_total,
        charge_breakdown: charge_breakdown,
        price: Price.create(
          currency: shipment_data[:addons][:customs_export_paper][:currency],
          value: shipment_data[:addons][:customs_export_paper][:value]
        ),
        parent: charge_breakdown.charge('grand_total')
      )
      @customs_export_paper = Charge.create(
        children_charge_category: ChargeCategory.from_code('customs_export_paper', shipment.tenant_id),
        charge_category: ChargeCategory.grand_total,
        charge_breakdown: charge_breakdown,
        price: Price.create(
          currency: shipment_data[:addons][:customs_export_paper][:currency],
          value: shipment_data[:addons][:customs_export_paper][:value]
        ),
        parent: @addons_charge
      )
      @addons_charge.update_price!
    end
    charge_breakdown.charge('grand_total').update_price!
    shipment.customs_credit = shipment_data[:customsCredit]
    shipment.notes = shipment_data['notes']

    cargo_item_types = {}
    if shipment.cargo_items
      cargo_items = shipment.cargo_items.map do |cargo_item|
        hs_code_hashes = hsCodes[cargo_item.id.to_s]

        if hs_code_hashes
          cargo_item.hs_codes = hs_code_hashes.map { |hs_code_hash| hs_code_hash['value'] }
          cargo_item.save!
        end
        hs_text = hsTexts[cargo_item.id.to_s]

        if hs_text
          cargo_item.customs_text = hs_text
          cargo_item.save!
        end
        cargo_item_types[cargo_item.cargo_item_type_id] = CargoItemType.find(cargo_item.cargo_item_type_id)
        cargo_item.set_chargeable_weight!
        cargo_item
      end
    end

    if shipment.containers
      containers = shipment.containers
      shipment.containers.map do |container|
        hs_code_hashes = hsCodes[container.id.to_s]

        if hs_code_hashes
          container.hs_codes = hs_code_hashes.map { |hs_code_hash| hs_code_hash['value'] }
          container.save!
        end
        hs_text = hsTexts[container.id.to_s]

        if hs_text
          container.customs_text = hs_text
          container.save!
        end
      end
    end

    if shipment.aggregated_cargo
      aggregated_cargo = shipment.aggregated_cargo
      aggregated_cargo.set_chargeable_weight!
      aggregated_cargo.save!
    end

    documents = shipment.documents.select { |doc| doc.file.attached? }.map do |doc|
      doc.as_json.merge(
        signed_url: Rails.application.routes.url_helpers.rails_blob_url(doc.file, disposition: 'attachment')
      )
    end

    shipment.eori = params[:shipment][:eori]

    shipment.save!

    origin_hub      = shipment.origin_hub
    destination_hub = shipment.destination_hub
    origin      = shipment.has_pre_carriage ? shipment.pickup_address   : shipment.origin_nexus
    destination = shipment.has_on_carriage  ? shipment.delivery_address : shipment.destination_nexus
    options = {
      methods: %i(selected_offer mode_of_transport service_level vessel_name carrier),
      include: [{ destination_nexus: {} }, { origin_nexus: {} }, { destination_hub: {} }, { origin_hub: {} }]
    }
    shipment_as_json = shipment.as_json(options).merge(
      pickup_address: shipment.pickup_address_with_country,
      delivery_address: shipment.delivery_address_with_country
    )
    addresses = {
      startHub: { data: origin_hub, location: origin_hub.nexus.to_custom_hash },
      endHub: { data: destination_hub, location: destination_hub.nexus.to_custom_hash },
      origin: origin.to_custom_hash,
      destination: destination.to_custom_hash
    }

    {
      shipment: shipment_as_json,
      cargoItems: cargo_items      || nil,
      containers: containers       || nil,
      aggregatedCargo: aggregated_cargo || nil,
      addresses: addresses,
      consignee: consignee,
      notifyees: notifyees,
      shipper: shipper,
      documents: documents,
      cargoItemTypes: cargo_item_types
    }
  end

  def self.request_shipment(params, current_user)
    shipment = Shipment.find(params[:shipment_id])
    shipment.status = current_user.confirmed? ? 'requested' : 'requested_by_unconfirmed_account'
    shipment.booking_placed_at = DateTime.now
    shipment.save!
    message = build_request_shipment_message(current_user, shipment)
    add_message_to_convo(current_user, message, true)
    shipment
  end

  def self.build_request_shipment_message(current_user, shipment)
    message = "
      Thank you for making your booking through #{current_user.tenant.name}.
      You will be notified upon confirmation of the order.
    "
    unless current_user.confirmed?
      message += "\n
        Please note that your order is pending Email Confirmation.
        #{current_user.tenant.name} will not confirm your order until the
        email associated with this account is validated.
        To confirm your email, please follow the link sent to your email.
      "
    end

    {
      title: 'Booking Received',
      message: message,
      shipmentRef: shipment.imc_reference
    }
  end

  def self.contact_address_params(resource)
    resource.require(:address)
            .permit(:street, :streetNumber, :zipCode, :city, :country)
            .to_h.deep_transform_keys(&:underscore)
  end

  def self.contact_params(resource, address_id = nil)
    resource.require(:contact)
            .permit(:companyName, :firstName, :lastName, :email, :phone)
            .to_h.deep_transform_keys(&:underscore)
            .merge(address_id: address_id)
  end

  def self.choose_offer(params, current_user) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    shipment = Shipment.find(params[:shipment_id])

    shipment.user_id = current_user.id
    shipment.customs_credit = params[:customs_credit]
    shipment.trip_id = params[:schedule]['trip_id']
    copy_charge_breakdowns(shipment, params[:schedule][:charge_trip_id], params[:schedule]['trip_id'])

    @schedule = params[:schedule].as_json

    shipment.itinerary = Trip.find(@schedule['trip_id']).itinerary
    case shipment.load_type
    when 'cargo_item'
      @dangerous = false
      res = shipment.cargo_items.where(dangerous_goods: true)
      @dangerous = true unless res.empty?
    when 'container'
      @dangerous = false
      res = shipment.containers.where(dangerous_goods: true)
      @dangerous = true unless res.empty?
    end
    @origin_hub      = Hub.find(@schedule['origin_hub']['id'])
    @destination_hub = Hub.find(@schedule['destination_hub']['id'])
    if shipment.has_pre_carriage
      trucking_seconds = shipment.trucking['pre_carriage']['trucking_time_in_seconds'].seconds
      shipment.planned_pickup_date = shipment.trip.closing_date - 1.day - trucking_seconds
    else
      shipment.planned_origin_drop_off_date = shipment.trip.closing_date - 1.day
    end
    shipment.origin_hub        = @origin_hub
    shipment.destination_hub   = @destination_hub
    shipment.origin_nexus      = @origin_hub.nexus
    shipment.destination_nexus = @destination_hub.nexus
    shipment.closing_date      = @schedule['closing_date']
    shipment.planned_etd       = @schedule['etd']
    shipment.planned_eta       = @schedule['eta']
    documents = Hash.new { |h, k| h[k] = [] }
    shipment.documents.each do |doc|
      documents[doc.doc_type] << doc
    end

    @user_addresses = current_user.user_addresses.map do |uloc|
      {
        address: uloc.address.to_custom_hash,
        contact: current_user.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    @contacts = current_user.contacts.map do |contact|
      {
        address: contact.address.try(:to_custom_hash) || {},
        contact: contact.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    hub_route = @schedule['hub_route_id']
    cargo_items = shipment.cargo_items
    containers = shipment.containers
    if containers.present?
      cargoKey = containers.first.size_class.dup
      customsKey = cargoKey.dup
      cargos = containers
    else
      cargoKey = 'lcl'
      customsKey = 'lcl'
      cargos = cargo_items
    end

    shipment.transport_category = shipment.trip.vehicle.transport_categories.find_by(name: 'any', cargo_class: cargoKey)
    shipment.save!
    origin_customs_fee = @origin_hub.get_customs(
      customsKey,
      shipment.mode_of_transport,
      'export',
      shipment.trip.tenant_vehicle_id,
      shipment.destination_hub_id
    )
    destination_customs_fee = @destination_hub.get_customs(
      customsKey,
      shipment.mode_of_transport,
      'import',
      shipment.trip.tenant_vehicle_id,
      shipment.origin_hub_id
    )
    addons = Addon.prepare_addons(
      @origin_hub,
      @destination_hub,
      cargoKey,
      shipment.trip.tenant_vehicle_id,
      shipment.mode_of_transport,
      cargos,
      current_user
    )

    import_fees = if destination_customs_fee
                    calc_customs_fees(
                      destination_customs_fee['fees'],
                      cargos,
                      shipment.load_type,
                      current_user,
                      shipment.mode_of_transport
                    )
                  else
                    { unknown: true }
                  end
    export_fees = if origin_customs_fee
                    calc_customs_fees(
                      origin_customs_fee['fees'],
                      cargos,
                      shipment.load_type,
                      current_user,
                      shipment.mode_of_transport
                    )
                  else
                    { unknown: true }
                  end
    total_fees = { total: { value: 0, currency: current_user.currency } }
    total_fees[:total][:value] += import_fees['total'][:value] if import_fees['total'] && import_fees['total'][:value]
    total_fees[:total][:value] += export_fees['total'][:value] if export_fees['total'] && export_fees['total'][:value]
    customs_fee = {
      import: destination_customs_fee ? import_fees : { unknown: true },
      export: origin_customs_fee ? export_fees : { unknown: true },
      total: total_fees
    }
    hubs = {
      startHub: { data: @origin_hub, address: @origin_hub.nexus },
      endHub: { data: @destination_hub, address: @destination_hub.nexus }
    }
    options = {
      methods: %i(selected_offer mode_of_transport service_level vessel_name carrier),
      include: [{ destination_nexus: {} }, { origin_nexus: {} }, { destination_hub: {} }, { origin_hub: {} }]
    }
    origin      = shipment.has_pre_carriage ? shipment.pickup_address   : shipment.origin_nexus
    destination = shipment.has_on_carriage  ? shipment.delivery_address : shipment.destination_nexus
    shipment_as_json = shipment.as_json(options).merge(
      pickup_address: shipment.pickup_address_with_country,
      delivery_address: shipment.delivery_address_with_country
    )
    {
      shipment: shipment_as_json,
      hubs: hubs,
      contacts: @contacts,
      userLocations: @user_addresses,
      schedule: @schedule,
      dangerousGoods: @dangerous,
      documents: documents,
      containers: containers,
      cargoItems: cargo_items,
      customs: customs_fee,
      addons: addons,
      addresses: {
        origin: origin.try(:to_custom_hash),
        destination: destination.try(:to_custom_hash)
      }
    }
  end

  def self.reuse_booking_data(id, _user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    old_shipment = Shipment.find(id)
    new_shipment_json = old_shipment.clone.as_json
    ids_to_remove = %w(has_pre_carriage has_on_carriage id selected_day)
    ids_to_remove.each do |rid|
      new_shipment_json.delete(rid)
    end
    new_shipment_json['selected_day'] = DateTime.new + 5.days
    new_shipment = Shipment.create!(new_shipment_json)
    if old_shipment.aggregated_cargo
      reuse_aggregrated_cargo(new_shipment, old_shipment.aggregated_cargo)
    else
      reuse_cargo_units(new_shipment, old_shipment.cargo_units)
    end
    params = {
      shipment_id: new_shipment.id,
      shipment: new_shipment.as_json
    }

    itinerary_ids = current_user.tenant.itineraries.ids.reject do |id|
      Pricing.where(itinerary_id: id).for_load_type(load_type).empty?
    end

    routes_data = Route.detailed_hashes_from_itinerary_ids(
      itinerary_ids,
      with_truck_types: { load_type: load_type }
    )

    {
      shipment: shipment,
      routes: routes_data[:route_hashes],
      lookup_tables_for_routes: routes_data[:look_ups],
      cargo_item_types: tenant.cargo_item_types,
      max_dimensions: tenant.max_dimensions,
      max_aggregate_dimensions: tenant.max_aggregate_dimensions
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def self.search_contacts(contact_params, current_user)
    contact_email = contact_params['email']
    existing_contact = current_user.contacts.where(email: contact_email).first
    if existing_contact
      return existing_contact
    else
      current_user.contacts.create(contact_params(resource, contact_address.id))
    end
  end

  def self.reuse_cargo_units(shipment, cargo_units)
    cargo_units.each do |cargo_unit|
      cargo_json = cargo_unit.clone.as_json
      cargo_json.delete('id')
      cargo_json.delete('shipment_id')
      shipment.cargo_units.create!(cargo_json)
    end
  end

  def self.reuse_contacts(old_shipment, new_shipment)
    old_shipment.shipment_contacts.each do |old_contact|
      new_contact_json = old_contact.clone.as_json
      new_contact_json.delete('id')
      new_contact_json.delete('shipment_id')
      new_shipment.shipment_contacts.create!(new_contact_json)
    end
  end

  def self.view_more_schedules(trip_id, delta) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    trip = Trip.find(trip_id)
    trips = delta.to_i.positive? ? trip.later_trips : trip.earlier_trips.sort_by(&:start_date)
    final_results = false

    trips = trip.last_trips.sort_by(&:start_date) if trips.empty? && delta.to_i.positive?

    final_results = true if (trips.length < 5 || trips.empty?) && delta.to_i.positive?

    trips = trip.earliest_trips.sort_by(&:start_date) if (trips.length < 5 || trips.empty?) && !delta.to_i.positive?

    {
      schedules: Schedule.from_trips(trips),
      itinerary_id: trip.itinerary_id,
      tenant_vehicle_id: trip.tenant_vehicle_id,
      finalResults: final_results
    }
  end

  def self.reuse_aggregrated_cargo(shipment, aggregated_cargo)
    aggregated_cargo_json = aggregated_cargo.clone.as_json
    aggregated_cargo_json.delete('id')
    aggregated_cargo_json.delete('shipment_id')
    shipment.aggregated_cargo.create!(aggregated_cargo_json)
  end

  def self.save_pdf_quotes(shipment, tenant, schedules)
    main_quote = ShippingTools.create_shipments_from_quotation(shipment, schedules)
    @quotes = main_quote.shipments.map(&:selected_offer)
    logo = Base64.encode64(Net::HTTP.get(URI(tenant.theme['logoLarge'])))
    QuoteMailer.quotation_admin_email(main_quote).deliver_later if tenant.scope['send_email_on_quote_download']
    quotation = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      template: 'shipments/pdfs/quotations.pdf.erb',
      margin: { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: shipment,
      shipments: main_quote.shipments,
      quotes: @quotes,
      logo: logo,
      quotation: main_quote,
      name: 'quotation',
      remarks: Remark.where(tenant_id: tenant.id).order(order: :asc)
    )
    quotation.generate
  end

  def self.save_and_send_quotes(shipment, schedules, email)
    main_quote = ShippingTools.create_shipments_from_quotation(shipment, schedules)
    QuoteMailer.quotation_email(shipment, main_quote.shipments.to_a, email, main_quote).deliver_later
    QuoteMailer.quotation_admin_email(main_quote).deliver_later if shipment.tenant.scope['send_email_on_quote_email']
  end

  def self.tenant_notification_email(user, shipment)
    ShipmentMailer.tenant_notification(user, shipment).deliver_later
  end

  def self.shipper_notification_email(user, shipment)
    ShipmentMailer.shipper_notification(user, shipment).deliver_later
  end

  def self.shipper_welcome_email(user, shipment)
    no_welcome_content = Content.where(tenant_id: user.tenant_id, component: 'WelcomeMail').empty?
    WelcomeMailer.welcome_email(user, shipment).deliver_later unless no_welcome_content
  end

  def self.shipper_confirmation_email(user, shipment)
    ShipmentMailer.shipper_confirmation(
      user,
      shipment
    ).deliver_later
  end

  def get_hs_code_hash(codes)
    resp = get_items_by_key_values(false, 'hsCodes', '_id', codes)
    results = {}

    resp.each do |hs|
      results[hs['_id']] = hs
    end
    results
  end

  def self.copy_charge_breakdowns(shipment, original_trip_id, new_trip_id)
    shipment.charge_breakdowns.find_by(trip_id: new_trip_id) && return

    charge_breakdown = shipment.charge_breakdowns.find_by(trip_id: original_trip_id)
    new_charge_breakdown = charge_breakdown.dup
    new_charge_breakdown.update(trip_id: new_trip_id)

    new_charge_breakdown.dup_charges(charge_breakdown: charge_breakdown)
  end

  def self.create_shipment_from_result(main_quote:, original_shipment:, result:) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    schedule = result['schedules'].first
    trip = Trip.find(schedule['trip_id'])
    on_carriage_hash = (original_shipment.trucking['on_carriage'] if result['quote']['trucking_on'])
    pre_carriage_hash = (original_shipment.trucking['pre_carriage'] if result['quote']['trucking_pre'])
    new_shipment = main_quote.shipments.create!(
      status: 'quoted',
      user_id: original_shipment.user_id,
      imc_reference: original_shipment.imc_reference,
      origin_hub_id: schedule['origin_hub']['id'],
      destination_hub_id: schedule['destination_hub']['id'],
      origin_nexus_id: original_shipment.origin_nexus_id || original_shipment&.origin_hub&.nexus_id,
      destination_nexus_id: original_shipment.destination_nexus_id,
      quotation_id: schedule['id'],
      trip_id: trip.id,
      booking_placed_at: DateTime.now,
      closing_date: original_shipment.closing_date,
      planned_eta: original_shipment.planned_eta,
      planned_etd: original_shipment.planned_etd,
      trucking: {
        pre_carriage: pre_carriage_hash,
        on_carriage: on_carriage_hash
      },
      load_type: original_shipment.load_type,
      itinerary_id: trip.itinerary_id,
      desired_start_date: original_shipment.desired_start_date
    )
    charge_category_map = {}
    original_shipment.cargo_units.each do |unit|
      new_unit = unit.dup
      new_unit.shipment_id = new_shipment.id
      new_unit.save!
      charge_category_map[unit.id] = new_unit.id
    end
    if new_shipment.lcl? && !new_shipment.aggregated_cargo.nil?
      new_shipment.aggregated_cargo.set_chargeable_weight!
    elsif new_shipment.lcl? && new_shipment.aggregated_cargo.nil?
      new_shipment.cargo_units.map(&:set_chargeable_weight!)
    end

    original_shipment.charge_breakdowns.where(trip: trip).each do |charge_breakdown|
      new_charge_breakdown = charge_breakdown.dup
      new_charge_breakdown.update(shipment: new_shipment)
      new_charge_breakdown.dup_charges(charge_breakdown: charge_breakdown)
      %w(import export cargo).each do |charge_key|
        next if new_charge_breakdown.charge(charge_key).nil?

        new_charge_breakdown.charge(charge_key).children.each do |new_charge|
          old_charge_category = new_charge&.children_charge_category
          next if old_charge_category&.cargo_unit_id.nil?

          new_charge_category = old_charge_category.dup
          new_charge_category.cargo_unit_id = charge_category_map[old_charge_category.cargo_unit_id]
          new_charge_category.save!
          new_charge.children_charge_category = new_charge_category
          new_charge.save!
        end
      end
    end
    new_shipment.save!
  end
end
