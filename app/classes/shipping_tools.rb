# frozen_string_literal: true

require 'bigdecimal'
require 'net/http'

class ShippingTools
  InternalError = Class.new(StandardError)
  ShipmentNotFound = Class.new(StandardError)
  DataMappingError = Class.new(StandardError)
  ContactsRedundancyError = Class.new(StandardError)

  attr_reader :current_organization

  def initialize
    @current_organization = ::Organizations::Organization.current
  end

  def create_shipments_from_quotation(shipment, results, sandbox = nil)
    main_quote = ShippingTools.new.handle_existing_quote(shipment, results, sandbox)
    results.each do |result|
      next unless main_quote.shipments.where(trip_id: result['meta']['charge_trip_id']).empty?

      ShippingTools.new.create_shipment_from_result(
        main_quote: main_quote,
        original_shipment: shipment,
        result: result.with_indifferent_access,
        sandbox: sandbox
      )
    end
    main_quote.shipments.map(&:reload)
    main_quote
  end

  def handle_existing_quote(shipment, results, sandbox = nil)
    existing_quote = Legacy::Quotation.find_by(
      user: shipment.user,
      original_shipment: shipment,
      sandbox: sandbox
    )

    trip_ids = results.map { |r| r['meta']['charge_trip_id'] }
    if existing_quote && shipment.updated_at < existing_quote.updated_at
      main_quote = existing_quote
      main_quote.shipments.where.not(trip_id: trip_ids).destroy_all
    elsif existing_quote && shipment.updated_at > existing_quote.updated_at
      main_quote = existing_quote
      main_quote.shipments.destroy_all
    elsif !existing_quote
      main_quote = Legacy::Quotation.create(
        user: shipment.user,
        original_shipment: shipment,
        sandbox: sandbox,
        billing: shipment.billing
      )
    end

    main_quote.touch unless main_quote.new_record?
    main_quote
  end

  def create_shipment(details, current_user, sandbox = nil)
    scope = OrganizationManager::ScopeService.new(
      target: current_user,
      organization: current_organization
    ).fetch

    raise ApplicationError::NotLoggedIn if scope[:closed_shop] && current_user.blank?

    load_type = details['loadType'].underscore
    direction = details['direction']

    shipment = Legacy::Shipment.new(
      user: current_user,
      status: 'booking_process_started',
      load_type: load_type,
      direction: direction,
      organization: current_organization,
      sandbox: sandbox
    )
    shipment.save!

    routes_data = Api::Routing::LegacyRoutingService.routes(
      organization: current_organization,
      user: current_user,
      scope: scope,
      load_type: load_type
    )

    {
      shipment: shipment,
      routes: routes_data[:route_hashes],
      lookup_tables_for_routes: routes_data[:look_ups],
      cargo_item_types: Legacy::TenantCargoItemType.where(organization: current_organization).map(&:cargo_item_type),
      max_dimensions: Legacy::MaxDimensionsBundle.unit.where(organization: current_organization).to_max_dimensions_hash,
      max_aggregate_dimensions: Legacy::MaxDimensionsBundle.aggregate.where(organization: current_organization).to_max_dimensions_hash,
      last_available_date: Date.today
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def get_offers(params, current_user, sandbox = nil)
    scope = OrganizationManager::ScopeService.new(
      target: current_user,
      organization: current_organization
    ).fetch

    raise ApplicationError::NotLoggedIn if scope[:closed_after_map] && current_user.blank?

    shipment = Legacy::Shipment.where(sandbox: sandbox).find(params[:shipment_id])
    offer_calculator = OfferCalculator::Calculator.new(shipment: shipment, params: params, user: current_user, sandbox: sandbox)

    Skylight.instrument title: 'OfferCalculator Perform' do
      offer_calculator.perform
    end

    offer_calculator.shipment.save!
    cargo_units = if offer_calculator.shipment.lcl? && !offer_calculator.shipment.aggregated_cargo
                    offer_calculator.shipment.cargo_units.map(&:with_cargo_type)
                  elsif offer_calculator.shipment.lcl? && offer_calculator.shipment.aggregated_cargo
                    [offer_calculator.shipment.aggregated_cargo]
                  else
                    offer_calculator.shipment.cargo_units
                  end

    quote = if scope['open_quotation_tool'] || scope['closed_quotation_tool']
              Skylight.instrument title: 'Create Shipments From Quote' do
                ShippingTools.new.create_shipments_from_quotation(
                  offer_calculator.shipment,
                  offer_calculator.detailed_schedules.map(&:deep_stringify_keys!)
                )
              end
            end
    if scope.fetch(:email_all_quotes) && offer_calculator.shipment.billing == 'external'
      QuoteMailer.quotation_admin_email(quote, offer_calculator.shipment).deliver_later
    end

    {
      shipment: offer_calculator.shipment,
      results: offer_calculator.detailed_schedules,
      originHubs: offer_calculator.hubs[:origin],
      destinationHubs: offer_calculator.hubs[:destination],
      cargoUnits: cargo_units,
      aggregatedCargo: offer_calculator.shipment.aggregated_cargo
    }
  rescue OfferCalculator::TruckingTools::LoadMeterageExceeded
    raise ApplicationError::LoadMeterageExceeded
  rescue OfferCalculator::Calculator::MissingTruckingData
    raise ApplicationError::MissingTruckingData
  rescue OfferCalculator::Calculator::InvalidPickupAddress
    raise ApplicationError::InvalidPickupAddress
  rescue OfferCalculator::Calculator::InvalidDeliveryAddress
    raise ApplicationError::InvalidDeliveryAddress
  rescue OfferCalculator::Calculator::InvalidLocalChargeResult
    raise ApplicationError::InvalidLocalChargeResult
  rescue OfferCalculator::Calculator::InvalidFreightResult
    raise ApplicationError::InvalidFreightResult
  rescue OfferCalculator::Calculator::NoDirectionsFound
    raise ApplicationError::NoDirectionsFound
  rescue OfferCalculator::Calculator::NoRoute
    raise ApplicationError::NoRoute
  rescue OfferCalculator::Calculator::InvalidRoutes
    raise ApplicationError::InvalidRoutes
  rescue OfferCalculator::Calculator::NoValidPricings
    raise ApplicationError::NoValidPricings
  rescue OfferCalculator::Calculator::NoValidSchedules
    raise ApplicationError::NoValidSchedules
  rescue ArgumentError
    raise ApplicationError::InternalError
  end

  def generate_shipment_pdf(shipment:, sandbox: nil)
    document = Pdf::Service.new(user: shipment.user, organization: shipment.organization).shipment_pdf(shipment: shipment)
    document.attachment
  end

  def update_shipment(params, current_user, sandbox = nil)
    shipment = Shipment.where(sandbox: sandbox).find(params[:shipment_id])
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
    contact_address = Address.create_and_geocode(contact_address_params(resource).merge(sandbox: sandbox))
    contact_params = contact_params(resource, contact_address.id)
    contact = search_contacts(contact_params, current_user, sandbox)
    shipment.shipment_contacts.find_or_create_by(
      contact_id: contact.id,
      contact_type: 'shipper',
      sandbox: sandbox
    )
    shipper = { data: contact, address: contact_address.to_custom_hash }

    # Consignee
    resource = shipment_data.require(:consignee)
    contact_address = Address.create_and_geocode(contact_address_params(resource).merge(sandbox: sandbox))
    contact_params = contact_params(resource, contact_address.id)
    contact = search_contacts(contact_params, current_user, sandbox)

    consignee = shipment.shipment_contacts.find_or_create_by(
      contact_id: contact.id,
      contact_type: 'consignee',
      sandbox: sandbox
    )

    raise ApplicationError::ContactsRedundancyError if consignee.invalid?

    consignee = { data: contact, address: contact_address.to_custom_hash }

    # Notifyees
    notifyees = shipment_data[:notifyees].try(:map) do |resource|
      contact_params = contact_params(resource, nil)
      contact = search_contacts(contact_params, current_user, sandbox)
      shipment.shipment_contacts.find_or_create_by!(
        contact_id: contact.id,
        contact_type: 'notifyee',
        sandbox: sandbox
      )
      contact
    end || []

    ShippingTools.new.handle_extra_charges(shipment: shipment, shipment_data: shipment_data)
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

    documents = shipment.files.map do |doc|
      next unless doc.file.attached?

      doc.as_json.merge(
        signed_url: Rails.application.routes.url_helpers.rails_blob_url(doc.file, disposition: 'attachment')
      )
    end

    shipment.eori = params[:shipment][:eori]

    shipment.save!

    origin_hub      = shipment.origin_hub
    destination_hub = shipment.destination_hub
    origin = shipment.has_pre_carriage ? shipment.pickup_address : shipment.origin_nexus
    destination = shipment.has_on_carriage ? shipment.delivery_address : shipment.destination_nexus
    options = {
      methods: %i[mode_of_transport service_level vessel_name carrier voyage_code],
      include: [{ destination_nexus: {} }, { origin_nexus: {} }, { destination_hub: {} }, { origin_hub: {} }]
    }
    shipment_as_json = shipment.as_json(options).merge(
      selected_offer: shipment.selected_offer(Pdf::HiddenValueService.new(user: shipment.user).hide_total_args),
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
      documents: documents.compact,
      cargoItemTypes: cargo_item_types
    }
  end

  def request_shipment(params, current_user, sandbox = nil)
    shipment = Legacy::Shipment.find_by(id: params[:shipment_id], sandbox: sandbox)
    shipment.status = current_user.activation_state == 'active' ? 'requested' : 'requested_by_unconfirmed_account'
    shipment.booking_placed_at = DateTime.now
    shipment.save!

    cargo_creator = Cargo::Creator.new(legacy_shipment: shipment)
    cargo_creator.perform

    raise ApplicationError::DataMappingError if cargo_creator.errors.any?

    shipment_request_creator = Shipments::ShipmentRequestCreator.new(legacy_shipment: shipment, user: current_user, sandbox: sandbox)
    shipment_request_creator.create

    raise ApplicationError::DataMappingError if shipment_request_creator.errors.any?

    shipment_request = shipment_request_creator.shipment_request

    Integrations::Processor.process(shipment_request_id: shipment_request.id, organization_id: shipment_request.organization_id)

    shipment
  end

  def contact_address_params(resource)
    resource.require(:address)
            .permit(:street, :streetNumber, :zipCode, :city, :country)
            .to_h.deep_transform_keys(&:underscore)
  end

  def contact_params(resource, address_id = nil)
    resource.require(:contact)
            .permit(:companyName, :firstName, :lastName, :email, :phone)
            .to_h.deep_transform_keys(&:underscore)
            .merge(address_id: address_id)
  end

  def choose_offer(params, current_user, sandbox = nil)
    raise ApplicationError::NotLoggedIn if current_user.blank?

    shipment = Shipment.find_by(id: params[:shipment_id] || params[:id], sandbox: sandbox)

    raise ApplicationError::ShipmentNotFound if shipment.blank?

    shipment.meta['pricing_rate_data'] = params[:meta][:pricing_rate_data]
    shipment.meta['pricing_breakdown'] = params[:meta][:pricing_breakdown]

    shipment.user = current_user
    shipment.customs_credit = params[:customs_credit]
    shipment.trip_id = params[:schedule]['trip_id']
    shipment.tender_id = shipment.charge_breakdowns.find_by(trip_id: params[:schedule]['charge_trip_id']).tender_id
    shipment.meta['tender_id'] = shipment.tender_id

    copy_charge_breakdowns(shipment, params[:schedule][:charge_trip_id], params[:schedule]['trip_id'])

    @schedule = params[:schedule].as_json

    shipment.itinerary = Trip.find_by(id: @schedule['trip_id'], sandbox: sandbox)&.itinerary
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
    @origin_hub = Hub.find_by(id: @schedule['origin_hub']['id'], sandbox: sandbox)
    @destination_hub = Hub.find_by(id: @schedule['destination_hub']['id'], sandbox: sandbox)
    if shipment.has_pre_carriage?
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
    shipment.files.each do |doc|
      documents[doc.doc_type] << doc
    end

    @user_addresses = UserAddress.where(user: current_user).map do |uloc|
      {
        address: uloc.address.to_custom_hash,
        contact: current_user.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    cargo_items = shipment.cargo_items
    containers = shipment.containers
    aggregated_cargo = shipment.aggregated_cargo
    if containers.present?
      cargoKey = containers.first.size_class.dup
      customsKey = cargoKey.dup
      cargos = containers
    else
      cargoKey = 'lcl'
      customsKey = 'lcl'
      cargos = cargo_items.presence || [aggregated_cargo]
    end
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
    @pricing_tools = OfferCalculator::PricingTools.new(shipment: shipment, user: current_user)
    import_fees = if destination_customs_fee
                    @pricing_tools.calc_addon_charges(
                      charge: destination_customs_fee['fees'],
                      cargos: cargos,
                      user: current_user,
                      mode_of_transport: shipment.mode_of_transport
                    )
                  end
    export_fees = if origin_customs_fee
                    @pricing_tools.calc_addon_charges(
                      charge: origin_customs_fee['fees'],
                      cargos: cargos,
                      user: current_user,
                      mode_of_transport: shipment.mode_of_transport
                    )
                  end
    currency = Users::Settings.find_by(user: current_user).currency
    total_fees = { total: { value: 0, currency: currency } }
    total_fees[:total][:value] += import_fees.dig('total', 'value') if import_fees
    total_fees[:total][:value] += export_fees.dig('total', 'value') if export_fees

    customs_fee = { total: total_fees }
    customs_fee[:import] = import_fees if import_fees.present?
    customs_fee[:export] = export_fees if export_fees.present?

    hubs = {
      startHub: { data: @origin_hub, address: @origin_hub.nexus },
      endHub: { data: @destination_hub, address: @destination_hub.nexus }
    }
    options = {
      methods: %i[mode_of_transport service_level vessel_name carrier voyage_code],
      include: [{ destination_nexus: {} }, { origin_nexus: {} }, { destination_hub: {} }, { origin_hub: {} }]
    }
    origin = shipment.has_pre_carriage ? shipment.pickup_address : shipment.origin_nexus
    destination = shipment.has_on_carriage ? shipment.delivery_address : shipment.destination_nexus
    shipment_as_json = shipment.as_json(options).merge(
      selected_offer: shipment.selected_offer(Pdf::HiddenValueService.new(user: shipment.user).hide_total_args),
      pickup_address: shipment.pickup_address_with_country,
      delivery_address: shipment.delivery_address_with_country
    )
    {
      shipment: shipment_as_json,
      hubs: hubs,
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

  def search_contacts(contact_params, current_user, sandbox = nil)
    contact_email = contact_params['email']
    existing_contact = Contact.where(user: current_user, email: contact_email, sandbox: sandbox).first
    existing_contact || Contact.create(contact_params.merge(sandbox: sandbox, user: current_user))
  end

  def reuse_cargo_units(shipment, cargo_units)
    cargo_units.each do |cargo_unit|
      cargo_json = cargo_unit.clone.as_json
      cargo_json.delete('id')
      cargo_json.delete('shipment_id')
      shipment.cargo_units.create!(cargo_json)
    end
  end

  def reuse_contacts(old_shipment, new_shipment)
    old_shipment.shipment_contacts.each do |old_contact|
      new_contact_json = old_contact.clone.as_json
      new_contact_json.delete('id')
      new_contact_json.delete('shipment_id')
      new_shipment.shipment_contacts.create!(new_contact_json)
    end
  end

  def view_more_schedules(trip_id, delta, sandbox = nil)
    trip = Trip.find(trip_id)
    trips = if delta.to_i.positive?
              trip.later_trips(sandbox: sandbox)
            else
              trip.earlier_trips(sandbox: sandbox).sort_by(&:start_date)
            end
    final_results = false

    trips = trip.last_trips(sandbox: sandbox).sort_by(&:start_date) if trips.empty? && delta.to_i.positive?

    final_results = true if (trips.length < 5 || trips.empty?) && delta.to_i.positive?
    if (trips.length < 5 || trips.empty?) && !delta.to_i.positive?
      trips = trip.earliest_trips(sandbox: sandbox).sort_by(&:start_date)
    end

    {
      schedules: OfferCalculator::Schedule.from_trips(trips),
      itinerary_id: trip.itinerary_id,
      tenant_vehicle_id: trip.tenant_vehicle_id,
      finalResults: final_results
    }
  end

  def save_pdf_quotes(shipment, organization, schedules, sandbox = nil)
    main_quote = ShippingTools.new.create_shipments_from_quotation(shipment, schedules, sandbox)
    send_on_download = ::OrganizationManager::ScopeService.new(
      target: shipment.user
    ).fetch(:send_email_on_quote_download)
    QuoteMailer.quotation_admin_email(main_quote).deliver_later if send_on_download
    Pdf::Service.new(user: shipment.user, organization: organization).quotation_pdf(quotation: main_quote)
  end

  def save_and_send_quotes(shipment, schedules, email, sandbox = nil)
    main_quote = ShippingTools.new.create_shipments_from_quotation(shipment, schedules, sandbox)
    QuoteMailer.quotation_email(shipment, main_quote.shipments.to_a, email, main_quote, sandbox).deliver_later
    send_on_quote = ::OrganizationManager::ScopeService.new(
      target: shipment.user,
    ).fetch(:send_email_on_quote_email)
    QuoteMailer.quotation_admin_email(main_quote, sandbox).deliver_later if send_on_quote
  end

  def tenant_notification_email(user, shipment, sandbox = nil)
    ShipmentMailer.tenant_notification(user, shipment, sandbox).deliver_later
  end

  def shipper_notification_email(user, shipment, sandbox = nil)
    ShipmentMailer.shipper_notification(user, shipment, sandbox).deliver_later
  end

  def shipper_welcome_email(user, sandbox = nil)
    no_welcome_content = Legacy::Content.where(organization_id: user.organization_id, component: 'WelcomeMail').empty?
    WelcomeMailer.welcome_email(user, sandbox).deliver_later unless no_welcome_content
  end

  def shipper_confirmation_email(user, shipment, sandbox = nil)
    ShipmentMailer.shipper_confirmation(
      user,
      shipment,
      sandbox
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

  def copy_charge_breakdowns(shipment, original_trip_id, new_trip_id)
    shipment.charge_breakdowns.find_by(trip_id: new_trip_id) && return

    charge_breakdown = shipment.charge_breakdowns.find_by(trip_id: original_trip_id)
    new_charge_breakdown = charge_breakdown.dup
    new_charge_breakdown.update(trip_id: new_trip_id)

    new_charge_breakdown.dup_charges(charge_breakdown: charge_breakdown)
  end

  def create_shipment_from_result(main_quote:, original_shipment:, result:, sandbox: nil)
    schedule = result['schedules'].first
    trip = Trip.find(schedule['trip_id'])
    original_charge_breakdown = original_shipment.charge_breakdowns.find_by(trip: trip)
    origin_hub = Legacy::Hub.find(schedule['origin_hub']['id'])
    destination_hub = Legacy::Hub.find(schedule['destination_hub']['id'])
    new_shipment = main_quote.shipments.create!(
      status: 'quoted',
      user: original_shipment.user,
      organization: original_shipment.organization,
      imc_reference: original_shipment.imc_reference,
      origin_hub: origin_hub,
      destination_hub: destination_hub,
      origin_nexus_id: origin_hub.nexus_id,
      destination_nexus_id: destination_hub.nexus_id,
      quotation_id: schedule['id'],
      trip_id: trip.id,
      booking_placed_at: DateTime.now,
      closing_date: original_shipment.closing_date,
      planned_eta: trip.end_date,
      planned_etd: trip.start_date,
      trucking: original_shipment.trucking,
      tender_id: original_charge_breakdown.tender_id,
      load_type: original_shipment.load_type,
      itinerary_id: trip.itinerary_id,
      desired_start_date: original_shipment.desired_start_date,
      meta: result['meta'].slice('pricing_rate_data', 'pricing_breakdown', 'meta_id'),
      sandbox: sandbox,
      billing: original_shipment.billing
    )

    charge_category_map = {}

    if original_shipment.aggregated_cargo.present?
      new_shipment.aggregated_cargo = original_shipment.aggregated_cargo.dup
    else
      original_shipment.cargo_units.each do |unit|
        new_unit = unit.dup
        new_unit.shipment_id = new_shipment.id
        new_unit.save!
        charge_category_map[unit.id] = new_unit.id
      end
    end

    if new_shipment.lcl? && new_shipment.aggregated_cargo.present?
      new_shipment.aggregated_cargo.set_chargeable_weight!
    elsif new_shipment.lcl? && new_shipment.aggregated_cargo.nil?
      new_shipment.cargo_units.map(&:set_chargeable_weight!)
    end

    if new_shipment.has_pre_carriage?
      trucking_seconds = original_shipment.trucking['pre_carriage']['trucking_time_in_seconds'].seconds
      new_shipment.planned_pickup_date = trip.closing_date - 1.day - trucking_seconds
    else
      new_shipment.planned_origin_drop_off_date = trip.closing_date - 1.day
    end

    new_charge_breakdown = original_charge_breakdown.dup
    new_charge_breakdown.update(shipment: new_shipment)
    metadatum = Pricings::Metadatum.find_by(charge_breakdown_id: original_charge_breakdown.id)
    if metadatum
      new_metadatum = metadatum.dup.tap do |meta|
        meta.charge_breakdown_id = new_charge_breakdown.id
        meta.save
      end
    end

    new_charge_breakdown.dup_charges(charge_breakdown: original_charge_breakdown)
    %w[import export cargo trucking_pre trucking_on].each do |charge_key|
      next if new_charge_breakdown.charge(charge_key).nil?

      new_charge_breakdown.charge(charge_key).children.each do |new_charge|
        old_charge_category = new_charge&.children_charge_category
        next if old_charge_category.nil?

        new_charge_category = Legacy::ChargeCategory.find_or_initialize_by(
          code: old_charge_category.code,
          name: old_charge_category.name,
          organization_id: old_charge_category.organization_id,
          cargo_unit_id: charge_category_map[old_charge_category.cargo_unit_id]
        )
        new_charge_category.save!

        if metadatum && new_metadatum
          Pricings::Breakdown.where(metadatum_id: metadatum.id, cargo_unit_id: old_charge_category.cargo_unit_id)
                             .each do |breakdown|
                               breakdown.dup.tap do |breakd|
                                 breakd.update(
                                   metadatum_id: new_metadatum.id,
                                   cargo_unit_id: charge_category_map[old_charge_category.cargo_unit_id]
                                 )
                               end
                             end
        end
        new_charge.children_charge_category = new_charge_category
        new_charge.save!
      end
    end

    new_shipment.save!
  end

  def handle_extra_charges(shipment:, shipment_data:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    charge_breakdown = shipment.charge_breakdowns.selected
    tender = charge_breakdown.tender
    existing_insurance_charge = charge_breakdown.charge('insurance')
    existing_insurance_charge&.destroy
    tender.line_items.where(section: 'insurance_section').destroy_all
    existing_customs_charge = charge_breakdown.charge('customs')
    existing_customs_charge&.destroy
    tender.line_items.where(section: 'customs_section').destroy_all
    existing_addons_charge = charge_breakdown.charge('addons')
    existing_addons_charge&.destroy
    tender.line_items.where(section: 'addons_section').destroy_all
    grand_total_charge_category = Legacy::ChargeCategory.from_code(
      code: 'grand_total', name: 'Grand Total', organization_id: shipment.organization_id
    )
    if shipment_data[:insurance][:isSelected]
      insurance_parent_charge = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: 'insurance', organization_id: shipment.organization_id
        ),
        charge_category: grand_total_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment[:total_goods_value]['currency'], value: shipment_data[:insurance][:val]
        ),
        parent: charge_breakdown.charge('grand_total')
      )
      insurance_charge = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: 'freight_insurance', organization_id: shipment.organization_id
        ),
        charge_category: insurance_parent_charge.children_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment[:total_goods_value]['currency'], value: shipment_data[:insurance][:val]
        ),
        parent: insurance_parent_charge
      )
      tender.line_items.create(
        section: 'insurance_section',
        charge_category: insurance_charge.children_charge_category,
        original_amount: insurance_charge.price.money,
        amount: insurance_charge.price.money
      )
    end

    if shipment_data[:customs][:total][:val].to_d.positive? || shipment_data[:customs][:total][:hasUnknown]
      customs_parent_charge = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: 'customs', organization_id: shipment.organization_id
        ),
        charge_category: grand_total_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment_data[:customs][:total][:currency],
          value: shipment_data[:customs][:total][:val]
        ),
        parent: charge_breakdown.charge('grand_total')
      )
      %i[export import].each do |direction|
        if shipment_data.dig(:customs, direction, :bool)
          customs_charge = Legacy::Charge.create(
            children_charge_category: Legacy::ChargeCategory.from_code(
              code: "#{direction}_customs", organization_id: shipment.organization_id
            ),
            charge_category: customs_parent_charge.children_charge_category,
            charge_breakdown: charge_breakdown,
            price: Legacy::Price.create(
              currency: shipment_data[:customs][direction][:currency],
              value: shipment_data[:customs][direction][:val]
            ),
            parent: customs_parent_charge
          )
          tender.line_items.create(
            section: "customs_section",
            charge_category: customs_charge.children_charge_category,
            original_amount: customs_charge.price.money,
            amount: customs_charge.price.money
          )
        end
      end
      customs_parent_charge.update_price!
    end
    if shipment_data.dig(:addons, :customs_export_paper)
      addons_charge = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: 'addons', organization_id: shipment.organization_id
        ),
        charge_category: grand_total_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment_data[:addons][:customs_export_paper][:currency],
          value: shipment_data[:addons][:customs_export_paper][:value]
        ),
        parent: charge_breakdown.charge('grand_total')
      )
      customs_export_paper = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: 'customs_export_paper', organization_id: shipment.organization_id
        ),
        charge_category: addons_charge.children_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment_data[:addons][:customs_export_paper][:currency],
          value: shipment_data[:addons][:customs_export_paper][:value]
        ),
        parent: addons_charge
      )
      tender.line_items.create(
        section: "addons_section",
        charge_category: customs_export_paper.children_charge_category,
        original_amount: customs_export_paper.price.money,
        amount: customs_export_paper.price.money
      )
      addons_charge.update_price!
    end
    tender.amount = tender.line_items.sum(Money.new(0, tender.amount_currency), &:amount)
    tender.original_amount = tender.line_items.sum(Money.new(0, tender.amount_currency), &:original_amount)
    tender.save
    charge_breakdown.charge('grand_total').update_price!
  end
end
