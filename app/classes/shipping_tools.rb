# frozen_string_literal: true

module ShippingTools
  include PricingTools
  include MongoTools
  include NotificationTools
  extend PricingTools
  extend MongoTools
  extend NotificationTools

  def self.create_shipments_from_quotation(shipment, schedules)
    main_quote = Quotation.create(user_id: shipment.user_id)
    schedules.each do |schedule|
      trip = Trip.find(schedule['trip_id'])
      on_carriage_hash = !!schedule['quote']['trucking_on'] ?
      {
        truck_type: '',
        location_id: Location.geocoded_location(shipment.delivery_address).id
      } : nil
      pre_carriage_hash = !!schedule['quote']['trucking_pre'] ?
      {
        truck_type: '',
        location_id: Location.geocoded_location(shipment.pickup_address).id
      } : nil
      new_shipment = main_quote.shipments.create!(
        status: 'quoted',
        user_id: shipment.user_id,
        imc_reference: shipment.imc_reference,
        origin_hub_id: schedule['origin_hub']['id'],
        destination_hub_id: schedule['destination_hub']['id'],
        quotation_id: schedule['id'],
        trip_id: trip.id,
        booking_placed_at: shipment.booking_placed_at,
        closing_date: shipment.closing_date,
        planned_eta: shipment.planned_eta,
        planned_etd: shipment.planned_etd,
        trucking: {
          has_pre_carriage: pre_carriage_hash,
          has_on_carriage: on_carriage_hash
        },
        load_type: shipment.load_type,
        itinerary: trip.itinerary
      )
      new_shipment.cargo_items = shipment.cargo_items
      shipment.charge_breakdowns.each do |charge_breakdown|
        new_charge_breakdown = charge_breakdown.dup
        new_charge_breakdown_grand_total = charge_breakdown.grand_total.dup
        new_charge_breakdown.grand_total = new_charge_breakdown_grand_total
        charges = charge_breakdown.grand_total.children.each_with_object([]) do |charge, arr|
          new_charge = charge.dup
          new_charge.update(parent: new_charge_breakdown_grand_total)
          arr << new_charge
          charge.children.each do |child|
            new_child = child.dup
            new_child.update(parent: new_charge)
            arr << new_child
            child.children.each do |grandchild|
              new_grandchild = grandchild.dup
              new_grandchild.update(parent: new_child)
              arr << new_grandchild
            end
          end
        end

        new_charge_breakdown.charges += charges
        new_shipment.charge_breakdowns << new_charge_breakdown
      end
    end
    main_quote
  end

  def self.create_shipment(details, current_user)
    tenant = current_user.tenant
    load_type = details['loadType'].underscore
    direction = details['direction']
    shipment = Shipment.new(
      user_id:   current_user.id,
      status:    'booking_process_started',
      load_type: load_type,
      direction: direction,
      tenant_id: tenant.id
    )
    unless shipment.save
      puts shipment.errors.full_messages

      # TBD - Create custom errors (ApplicationError)
      shipment.save!
    end
    if tenant.scope['closed_quotation_tool']
      user_pricing_id = current_user.agency.agency_manager_id
      itinerary_ids = current_user.tenant.itineraries.ids.reject do |id|
        Pricing.where(itinerary_id: id, user_id: user_pricing_id).for_load_type(load_type).empty?
      end
    else
      itinerary_ids = current_user.tenant.itineraries.ids.reject do |id|
        Pricing.where(itinerary_id: id).for_load_type(load_type).empty?
      end
    end
    last_trip_date = last_trip(current_user)

    routes_data = Route.detailed_hashes_from_itinerary_ids(
      itinerary_ids,
      with_truck_types: { load_type: load_type }
    )

    {
      shipment:                 shipment,
      routes:                   routes_data[:route_hashes],
      lookup_tables_for_routes: routes_data[:look_ups],
      cargo_item_types:         tenant.cargo_item_types,
      max_dimensions:           tenant.max_dimensions,
      max_aggregate_dimensions: tenant.max_aggregate_dimensions,
      last_trip_date:           last_trip_date
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def self.get_offers(params, current_user)
    shipment = Shipment.find(params[:shipment_id])
    offer_calculator = OfferCalculator.new(shipment, params, current_user)

    offer_calculator.perform

    offer_calculator.shipment.save!
    last_trip_date = last_trip(current_user)
    {
      shipment:        offer_calculator.shipment,
      schedules:       offer_calculator.detailed_schedules,
      originHubs:      offer_calculator.hubs[:origin],
      destinationHubs: offer_calculator.hubs[:destination],
      cargoUnits:      offer_calculator.shipment.cargo_units,
      lastTripDate:    last_trip_date
    }
  end

  def create_document(file, shipment, type, user)
    if type != 'miscellaneous'
      existing_document = shipment.documents.where(doc_type: type).first
      if existing_document
        existing_document.update_file(file, shipment, type, user)
      else
        Document.new_upload(file, shipment, type, user)
      end
    else
      Document.new_upload(file, shipment, type, user)
    end
  end

  def self.update_shipment(params, current_user)
    tenant = current_user.tenant
    shipment = Shipment.find(params[:shipment_id])
    shipment_data = params[:shipment]

    hsCodes = shipment_data[:hsCodes].as_json
    hsTexts = shipment_data[:hsTexts].as_json
    shipment.assign_attributes(
      total_goods_value: shipment_data[:totalGoodsValue],
      cargo_notes:       shipment_data[:cargoNotes]
    )
    shipment.incoterm_text = shipment_data[:incotermText] if shipment_data[:incotermText]

    # Shipper
    resource = shipment_data.require(:shipper)
    contact_location = Location.create_and_geocode(contact_location_params(resource))
    contact_params = contact_params(resource, contact_location.id)
    contact = search_contacts(contact_params, current_user)
    shipment.shipment_contacts.find_or_create_by(contact_id: contact.id, contact_type: 'shipper')
    shipper = { data: contact, location: contact_location.to_custom_hash }
    # NOT CORRECT: UserLocation.create(user: current_user, location: contact_location) if shipment.export?

    # Consignee
    resource = shipment_data.require(:consignee)
    contact_location = Location.create_and_geocode(contact_location_params(resource))
    contact_params = contact_params(resource, contact_location.id)
    contact = search_contacts(contact_params, current_user)
    shipment.shipment_contacts.find_or_create_by!(contact_id: contact.id, contact_type: 'consignee')
    consignee = { data: contact, location: contact_location.to_custom_hash }
    # NOT CORRECT: UserLocation.create(user: current_user, location: contact_location) if shipment.import?

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
        children_charge_category: ChargeCategory.from_code('insurance'),
        charge_category:          ChargeCategory.grand_total,
        charge_breakdown:         charge_breakdown,
        price:                    Price.create(currency: shipment.user.currency, value: shipment_data[:insurance][:value]),
        parent:                   charge_breakdown.charge('grand_total')
      )
    end
    if shipment_data[:customs][:total][:val].to_d > 0 || shipment_data[:customs][:total][:hasUnknown]
      @customs_charge = Charge.create(
        children_charge_category: ChargeCategory.from_code('customs'),
        charge_category:          ChargeCategory.grand_total,
        charge_breakdown:         charge_breakdown,
        price:                    Price.create(
          currency: shipment_data[:customs][:total][:currency],
          value: shipment_data[:customs][:total][:val]
        ),
        parent:                   charge_breakdown.charge('grand_total')
      )
      if shipment_data[:customs][:import][:bool]
        @import_customs_charge = Charge.create(
          children_charge_category: ChargeCategory.from_code('import_customs'),
          charge_category:          ChargeCategory.grand_total,
          charge_breakdown:         charge_breakdown,
          price:                    Price.create(
            currency: shipment_data[:customs][:import][:currency],
            value: shipment_data[:customs][:import][:val]
          ),
          parent:                   @customs_charge
        )
      end
      if shipment_data[:customs][:export][:bool]
        @export_customs_charge = Charge.create(
          children_charge_category: ChargeCategory.from_code('export_customs'),
          charge_category:          ChargeCategory.grand_total,
          charge_breakdown:         charge_breakdown,
          price:                    Price.create(
            currency: shipment_data[:customs][:total][:currency],
            value: shipment_data[:customs][:export][:val]
          ),
          parent:                   @customs_charge
        )
      end

      @customs_charge.update_price!
    end
    if shipment_data[:addons][:customs_export_paper]
      @addons_charge = Charge.create(
        children_charge_category: ChargeCategory.from_code('addons'),
        charge_category:          ChargeCategory.grand_total,
        charge_breakdown:         charge_breakdown,
        price:                    Price.create(
          currency: shipment_data[:addons][:customs_export_paper][:currency],
          value: shipment_data[:addons][:customs_export_paper][:value]
        ),
        parent:                   charge_breakdown.charge('grand_total')
      )
      @customs_export_paper = Charge.create(
        children_charge_category: ChargeCategory.from_code('customs_export_paper'),
        charge_category:          ChargeCategory.grand_total,
        charge_breakdown:         charge_breakdown,
        price:                    Price.create(
          currency: shipment_data[:addons][:customs_export_paper][:currency],
          value: shipment_data[:addons][:customs_export_paper][:value]
        ),
        parent:                   @addons_charge
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
    end

    documents = shipment.documents.map do |doc|
      tmp = doc.as_json
      tmp['signed_url'] = doc.get_signed_url
      tmp
    end

    shipment.save!

    origin_hub      = shipment.origin_hub
    destination_hub = shipment.destination_hub
    origin      = shipment.has_pre_carriage ? shipment.pickup_address   : shipment.origin_nexus
    destination = shipment.has_on_carriage  ? shipment.delivery_address : shipment.destination_nexus

    locations = {
      startHub:    { data: origin_hub,      location: origin_hub.nexus.to_custom_hash },
      endHub:      { data: destination_hub, location: destination_hub.nexus.to_custom_hash },
      origin:      origin.to_custom_hash,
      destination: destination.to_custom_hash
    }

    {
      shipment:        shipment.as_options_json,
      cargoItems:      cargo_items      || nil,
      containers:      containers       || nil,
      aggregatedCargo: aggregated_cargo || nil,
      locations:       locations,
      consignee:       consignee,
      notifyees:       notifyees,
      shipper:         shipper,
      documents:       documents,
      cargoItemTypes:  cargo_item_types
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
      title:       'Booking Received',
      message:     message,
      shipmentRef: shipment.imc_reference
    }
  end

  def self.contact_location_params(resource)
    resource.require(:location)
            .permit(:street, :streetNumber, :zipCode, :city, :country)
            .to_h.deep_transform_keys(&:underscore)
  end

  def self.contact_params(resource, location_id = nil)
    resource.require(:contact)
            .permit(:companyName, :firstName, :lastName, :email, :phone)
            .to_h.deep_transform_keys(&:underscore)
            .merge(location_id: location_id)
  end

  def self.choose_offer(params, current_user)
    shipment = Shipment.find(params[:shipment_id])

    shipment.user_id =        params[:user_id]
    shipment.customs_credit = params[:customs_credit]

    shipment.trip_id =      params[:schedule]['trip_id']
    @schedule =             params[:schedule].as_json

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

    shipment.origin_hub        = @origin_hub
    shipment.destination_hub   = @destination_hub
    shipment.origin_nexus      = @origin_hub.nexus
    shipment.destination_nexus = @destination_hub.nexus
    shipment.closing_date      = @schedule['closing_date']
    shipment.planned_etd       = @schedule['etd']
    shipment.planned_eta       = @schedule['eta']
    documents = {}
    shipment.documents.each do |doc|
      documents[doc.doc_type] = doc
    end

    @user_locations = current_user.user_locations.map do |uloc|
      {
        location: uloc.location.to_custom_hash,
        contact:  current_user.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    @contacts = current_user.contacts.map do |contact|
      {
        location: contact.location.try(:to_custom_hash) || {},
        contact:  contact.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    hub_route = @schedule['hub_route_id']
    cargo_items = shipment.cargo_items
    containers = shipment.containers
    if containers.present?
      cargoKey = containers.first.size_class.dup
      customsKey = cargoKey.dup
      customsKey.slice! customsKey.rindex('f')
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
    addons = Addon.prepare_addons(@origin_hub, @destination_hub, cargoKey, shipment.trip.tenant_vehicle_id, shipment.mode_of_transport, cargos, current_user)

    import_fees = destination_customs_fee ? calc_customs_fees(destination_customs_fee['fees'], cargos, shipment.load_type, current_user, shipment.mode_of_transport) : { unknown: true }
    export_fees = origin_customs_fee ? calc_customs_fees(origin_customs_fee['fees'], cargos, shipment.load_type, current_user, shipment.mode_of_transport) : { unknown: true }
    total_fees = { total: { value: 0, currency: current_user.currency } }
    total_fees[:total][:value] += import_fees['total'][:value] if import_fees['total'] && import_fees['total'][:value]
    total_fees[:total][:value] += export_fees['total'][:value] if export_fees['total'] && export_fees['total'][:value]

    customs_fee = {
      import: destination_customs_fee ? import_fees : { unknown: true },
      export: origin_customs_fee ? export_fees : { unknown: true },
      total:  total_fees
    }
    hubs = {
      startHub: { data: @origin_hub,      location: @origin_hub.nexus },
      endHub:   { data: @destination_hub, location: @destination_hub.nexus }
    }
    options = { methods: %i(selected_offer mode_of_transport), include: [{ destination_nexus: {} }, { origin_nexus: {} }, { destination_hub: {} }, { origin_hub: {} }] }
    origin      = shipment.has_pre_carriage ? shipment.pickup_address   : shipment.origin_nexus
    destination = shipment.has_on_carriage  ? shipment.delivery_address : shipment.destination_nexus
    shipment_as_json = shipment.as_json(options).merge(
      pickup_address:   shipment.pickup_address_with_country,
      delivery_address: shipment.delivery_address_with_country
    )
    {
      shipment:       shipment_as_json,
      hubs:           hubs,
      contacts:       @contacts,
      userLocations:  @user_locations,
      schedule:       @schedule,
      dangerousGoods: @dangerous,
      documents:      documents,
      containers:     containers,
      cargoItems:     cargo_items,
      customs:        customs_fee,
      addons:         addons,
      locations:      {
        origin:      origin.try(:to_custom_hash),
        destination: destination.try(:to_custom_hash)
      }
    }
  end

  def self.reuse_booking_data(id, _user)
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
      shipment:                 shipment,
      routes:                   routes_data[:route_hashes],
      lookup_tables_for_routes: routes_data[:look_ups],
      cargo_item_types:         tenant.cargo_item_types,
      max_dimensions:           tenant.max_dimensions,
      max_aggregate_dimensions: tenant.max_aggregate_dimensions
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def self.search_contacts(contact_params, current_user)
    contact_email = contact_params['email']
    existing_contact = current_user.contacts.where(email: contact_email).first
    if existing_contact
      return existing_contact
    else
      current_user.contacts.create(contact_params(resource, contact_location.id))
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

  def self.reuse_aggregrated_cargo(shipment, aggregated_cargo)
    aggregated_cargo_json = aggregated_cargo.clone.as_json
    aggregated_cargo_json.delete('id')
    aggregated_cargo_json.delete('shipment_id')
    shipment.aggregated_cargo.create!(aggregated_cargo_json)
  end

  def self.tenant_notification_email(user, shipment)
    ShipmentMailer.tenant_notification(user, shipment).deliver_later if Rails.env.production? && ENV['BETA'] != 'true'
  end

  def self.shipper_notification_email(user, shipment)
    ShipmentMailer.shipper_notification(user, shipment).deliver_later if Rails.env.production? && ENV['BETA'] != 'true'
  end

  def self.shipper_confirmation_email(user, shipment)
    if Rails.env.production? && ENV['BETA'] != 'true'
      ShipmentMailer.shipper_confirmation(
        user,
        shipment
      ).deliver_later
    end
  end

  def get_shipment_pdf(params)
    shipment = Shipment.find_by_id(params[:shipment_id])
    pdf_string = render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_shipper.pdf', locals: { shipment: shipment })
    shipper_pdf = WickedPdf.new.pdf_from_string(pdf_string, margin: { top: 10, bottom: 5, left: 20, right: 20 })
    send_data shipper_pdf, filename: 'Booking_' + shipment.imc_reference + '.pdf'
  end

  def self.save_pdf_quotes(shipment, tenant, schedules)
    main_quote = ShippingTools.create_shipments_from_quotation(shipment, schedules)
    @quotes = main_quote.shipments.map(&:selected_offer)

    logo = Base64.encode64(HTTP.get(tenant.theme['logoLarge']).body)

    quotation = PdfHandler.new(
      layout:      'pdfs/simple.pdf.html.erb',
      template:    'shipments/pdfs/quotations.pdf.erb',
      margin:      { top: 10, bottom: 5, left: 8, right: 8 },
      shipment:    shipment,
      shipments:   main_quote.shipments,
      quotes:      @quotes,
      logo:        logo,
      quotation:   main_quote,
      name:        'quotation'
    )
    quotation.generate
    quotation.upload_quotes
  end

  def self.save_and_send_quotes(shipment, schedules, email)
    main_quote = ShippingTools.create_shipments_from_quotation(shipment, schedules)
    QuoteMailer.quotation_email(shipment, main_quote.shipments, email, main_quote).deliver_later if Rails.env.production? && ENV['BETA'] != 'true'
  end

  def self.tenant_notification_email(user, shipment)
    ShipmentMailer.tenant_notification(user, shipment).deliver_later if Rails.env.production? && ENV['BETA'] != 'true'
  end

  def self.shipper_notification_email(user, shipment)
    ShipmentMailer.shipper_notification(user, shipment).deliver_later if Rails.env.production? && ENV['BETA'] != 'true'
  end

  def self.shipper_confirmation_email(user, shipment)
    if Rails.env.production? && ENV['BETA'] != 'true'
      ShipmentMailer.shipper_confirmation(
        user,
        shipment
      ).deliver_later
    end
  end

  def self.last_trip(user)
    user.tenant.trips.order(:start_date)&.last&.start_date
  end

  def build_and_upload_pdf(args)
    doc_erb = ErbTemplate.new(
      layout:   args[:layout],
      template: args[:template],
      locals:   { shipment: args[:shipment] }
    )

    doc_string = WickedPdf.new.pdf_from_string(
      doc_erb.render,
      margin: args[:margin]
    )

    doc_name = "#{args[:name]}_#{args[:shipment].imc_reference}.pdf"

    File.open('tmp/' + doc_name, 'wb') { |file| file.write(doc_string) }
    doc_pdf = File.open('tmp/' + doc_name)

    doc = DocumentTools.new_upload_backend(doc_pdf, args[:shipment], args[:name], current_user)
    doc_url = doc.get_signed_url

    { name: doc_name, url: doc_url }
  end

  def send_booking_emails(shipment)
    if ENV['BETA'] != 'true'
      shipper_pdf = WickedPdf.new.pdf_from_string(render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_shipper.pdf', locals: { shipment: shipment }), margin: { top: 10, bottom: 5, left: 20, right: 20 })
      trucker_pdf = WickedPdf.new.pdf_from_string(render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_trucker.pdf', locals: { shipment: shipment }), margin: { top: 10, bottom: 5, left: 20, right: 20 })
      consolidator_pdf = WickedPdf.new.pdf_from_string(render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_consolidator.pdf', locals: { shipment: shipment }), margin: { top: 10, bottom: 5, left: 20, right: 20 })
      receiver_pdf = WickedPdf.new.pdf_from_string(render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_receiver.pdf', locals: { shipment: shipment }), margin: { top: 10, bottom: 5, left: 20, right: 20 })
      ShipmentMailer.summary_mail_shipper(shipment, 'Booking_' + shipment.imc_reference + '.pdf', shipper_pdf).deliver_now
      ShipmentMailer.summary_mail_trucker(shipment, 'Booking_' + shipment.imc_reference + '.pdf', trucker_pdf).deliver_now
      ShipmentMailer.summary_mail_consolidator(shipment, 'Booking_' + shipment.imc_reference + '.pdf', consolidator_pdf).deliver_now
      ShipmentMailer.summary_mail_receiver(shipment, 'Booking_' + shipment.imc_reference + '.pdf', receiver_pdf).deliver_now
    end
    # TBD - Set up flash message
  end

  def get_hs_code_hash(codes)
    resp = get_items_by_key_values(false, 'hsCodes', '_id', codes)
    results = {}

    resp.each do |hs|
      results[hs['_id']] = hs
    end
    results
  end
end
