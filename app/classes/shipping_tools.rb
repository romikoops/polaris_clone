# frozen_string_literal: true

require "bigdecimal"
require "net/http"

class ShippingTools
  InternalError = Class.new(StandardError)
  ShipmentNotFound = Class.new(StandardError)
  DataMappingError = Class.new(StandardError)
  ContactsRedundancyError = Class.new(StandardError)

  include Wheelhouse::ErrorHandler

  attr_reader :current_organization

  def initialize
    @current_organization = ::Organizations::Organization.current
  end

  def create_shipment(details, current_user)
    scope = OrganizationManager::ScopeService.new(
      target: current_user,
      organization: current_organization
    ).fetch

    raise ApplicationError::NotLoggedIn if scope[:closed_shop] && current_user.blank?

    load_type = details["loadType"].underscore
    direction = details["direction"]

    shipment = Legacy::Shipment.new(
      user: current_user,
      status: "booking_process_started",
      load_type: load_type,
      direction: direction,
      organization: current_organization
    )
    shipment.save!

    routes_data = Api::Routing::LegacyRoutingService.routes(
      organization: current_organization,
      user: current_user,
      scope: scope,
      load_type: load_type
    )
    cargo_classes = shipment.lcl? ? ["lcl"] : Legacy::Container::CARGO_CLASSES
    max_dimensions = Legacy::MaxDimensionsBundle.unit
      .where(organization: current_organization, cargo_class: cargo_classes)
      .to_max_dimensions_hash
    max_aggregate_dimensions = Legacy::MaxDimensionsBundle.aggregate
      .where(organization: current_organization, cargo_class: cargo_classes)
      .to_max_dimensions_hash

    {
      shipment: shipment,
      routes: routes_data[:route_hashes],
      lookup_tables_for_routes: routes_data[:look_ups],
      cargo_item_types: Legacy::TenantCargoItemType.where(
        organization: current_organization
      ).map(&:cargo_item_type),
      max_dimensions: max_dimensions,
      max_aggregate_dimensions: max_aggregate_dimensions,
      last_available_date: Time.zone.today
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def get_offers(params, current_user)
    scope = OrganizationManager::ScopeService.new(
      target: current_user,
      organization: current_organization
    ).fetch

    raise ApplicationError::NotLoggedIn if scope[:closed_after_map] && current_user.blank?

    shipment = Legacy::Shipment.find(params[:shipment_id]).tap do |tapped_shipment|
      tapped_shipment.update(user: current_user) if tapped_shipment.user_id.nil?
    end

    offer_calculator = OfferCalculator::Calculator.new(
      shipment: shipment,
      params: params,
      user: current_user,
      creator: current_user,
      wheelhouse: false
    )

    offer_results = offer_calculator.perform

    QuotationDecorator.new(offer_results.quotation, context: {scope: scope}).legacy_json
  rescue OfferCalculator::Errors::Failure => e
    handle_error(error: e)
  rescue ArgumentError
    raise ApplicationError::InternalError
  end

  def update_shipment(params, current_user)
    shipment = Shipment.find(params[:shipment_id])
    shipment_data = params[:shipment]

    hs_codes = shipment_data[:hsCodes].as_json
    hs_texts = shipment_data[:hsTexts].as_json
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
    shipment.shipment_contacts.find_or_create_by(
      contact_id: contact.id,
      contact_type: "shipper"
    )
    shipper = {data: contact, address: contact_address.to_custom_hash}

    # Consignee
    resource = shipment_data.require(:consignee)
    contact_address = Address.create_and_geocode(contact_address_params(resource))
    contact_params = contact_params(resource, contact_address.id)
    contact = search_contacts(contact_params, current_user)

    consignee = shipment.shipment_contacts.find_or_create_by(
      contact_id: contact.id,
      contact_type: "consignee"
    )

    raise ApplicationError::ContactsRedundancyError if consignee.invalid?

    consignee = {data: contact, address: contact_address.to_custom_hash}

    # Notifyees
    notifyees = shipment_data[:notifyees].try(:map) do |resource|
      contact_params = contact_params(resource, nil)
      contact = search_contacts(contact_params, current_user)
      shipment.shipment_contacts.find_or_create_by!(
        contact_id: contact.id,
        contact_type: "notifyee"
      )
      contact
    end || []

    ShippingTools.new.handle_extra_charges(shipment: shipment, shipment_data: shipment_data)
    shipment.customs_credit = shipment_data[:customsCredit]
    shipment.notes = shipment_data["notes"]

    cargo_item_types = {}
    if shipment.cargo_items
      cargo_items = shipment.cargo_items.map { |cargo_item|
        hs_code_hashes = hs_codes[cargo_item.id.to_s]

        if hs_code_hashes
          cargo_item.hs_codes = hs_code_hashes.map { |hs_code_hash| hs_code_hash["value"] }
          cargo_item.save!
        end
        hs_text = hs_texts[cargo_item.id.to_s]

        if hs_text
          cargo_item.customs_text = hs_text
          cargo_item.save!
        end
        cargo_item_types[cargo_item.cargo_item_type_id] = CargoItemType.find(cargo_item.cargo_item_type_id)
        cargo_item.set_chargeable_weight!
        cargo_item
      }
    end

    if shipment.containers
      containers = shipment.containers
      shipment.containers.map do |container|
        hs_code_hashes = hs_codes[container.id.to_s]

        if hs_code_hashes
          container.hs_codes = hs_code_hashes.map { |hs_code_hash| hs_code_hash["value"] }
          container.save!
        end
        hs_text = hs_texts[container.id.to_s]

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

    documents = shipment.files.map { |doc|
      next unless doc.file.attached?

      doc.as_json.merge(
        signed_url: Rails.application.routes.url_helpers.rails_blob_url(doc.file, disposition: "attachment")
      )
    }

    shipment.eori = params[:shipment][:eori]

    shipment.save!

    origin_hub = shipment.origin_hub
    destination_hub = shipment.destination_hub
    origin = shipment.has_pre_carriage ? shipment.pickup_address : shipment.origin_nexus
    destination = shipment.has_on_carriage ? shipment.delivery_address : shipment.destination_nexus
    options = {
      methods: %i[mode_of_transport service_level vessel_name carrier voyage_code],
      include: [{destination_nexus: {}}, {origin_nexus: {}}, {destination_hub: {}}, {origin_hub: {}}]
    }
    shipment_as_json = shipment.as_json(options).merge(
      selected_offer: shipment.selected_offer(Pdf::HiddenValueService.new(user: shipment.user).hide_total_args),
      pickup_address: shipment.pickup_address_with_country,
      delivery_address: shipment.delivery_address_with_country
    )
    addresses = {
      startHub: {data: origin_hub, location: origin_hub.nexus.to_custom_hash},
      endHub: {data: destination_hub, location: destination_hub.nexus.to_custom_hash},
      origin: origin.to_custom_hash,
      destination: destination.to_custom_hash
    }

    {
      shipment: shipment_as_json,
      cargoItems: cargo_items || nil,
      containers: containers || nil,
      aggregatedCargo: aggregated_cargo || nil,
      addresses: addresses,
      consignee: consignee,
      notifyees: notifyees,
      shipper: shipper,
      documents: documents.compact,
      cargoItemTypes: cargo_item_types
    }
  end

  def request_shipment(params, current_user)
    shipment = Legacy::Shipment.find_by(id: params[:shipment_id])
    shipment.status = current_user.activation_state == "active" ? "requested" : "requested_by_unconfirmed_account"
    shipment.booking_placed_at = DateTime.now
    shipment.save!

    shipment_request_creator = Shipments::ShipmentRequestCreator.new(legacy_shipment: shipment, user: current_user)
    shipment_request_creator.create

    raise ApplicationError::DataMappingError if shipment_request_creator.errors.any?

    shipment_request = shipment_request_creator.shipment_request

    Integrations::Processor.process(
      shipment_request_id: shipment_request.id, organization_id: shipment_request.organization_id
    )

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

  def update_shipment_for_chosen_offer(shipment:, params:, current_user:)
    selected_tender = shipment.charge_breakdowns.find_by(trip_id: params[:schedule]["charge_trip_id"]).tender
    new_meta = shipment.meta
      .merge(tender_id: shipment.tender_id)
      .merge(params[:meta].slice(%i[pricing_rate_data pricing_breakdown]))
    shipment = update_shipment_routing(shipment: shipment, params: params)
    shipment.update(
      user: current_user,
      customs_credit: params[:customs_credit],
      trip_id: params[:schedule]["trip_id"],
      tender_id: selected_tender.id,
      imc_reference: selected_tender.imc_reference,
      meta: new_meta
    )
    update_quotation_owner(shipment: shipment, user: current_user)
    shipment
  end

  def update_shipment_routing(shipment:, params:)
    schedule = params[:schedule].as_json
    shipment.itinerary = Trip.find_by(id: schedule["trip_id"])&.itinerary
    origin_hub = Hub.find_by(id: schedule["origin_hub"]["id"])
    destination_hub = Hub.find_by(id: schedule["destination_hub"]["id"])
    shipment = update_shipment_trucking_info(shipment: shipment)
    shipment.assign_attributes(
      origin_hub: origin_hub,
      destination_hub: destination_hub,
      origin_nexus: origin_hub.nexus,
      destination_nexus: destination_hub.nexus,
      closing_date: schedule["closing_date"],
      planned_etd: schedule["etd"],
      planned_eta: schedule["eta"]
    )
    shipment
  end

  def update_shipment_trucking_info(shipment:)
    if shipment.has_pre_carriage?
      trucking_seconds = shipment.trucking["pre_carriage"]["trucking_time_in_seconds"].seconds
      shipment.planned_pickup_date = shipment.trip.closing_date - 1.day - trucking_seconds
    else
      shipment.planned_origin_drop_off_date = shipment.trip.closing_date - 1.day
    end
    shipment
  end

  def update_quotation_owner(shipment:, user:)
    ::Quotations::Quotation.where(legacy_shipment_id: shipment.id).update_all(
      user_id: user&.id,
      creator_id: user&.id
    )
  end

  def shipment_documents(shipment:)
    documents = Hash.new { |h, k| h[k] = [] }
    shipment.files.each do |doc|
      documents[doc.doc_type] << doc
    end
  end

  def user_addresses(user:)
    UserAddress.where(user: user).map do |uloc|
      {
        address: uloc.address.to_custom_hash,
        contact: user.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end
  end

  def fetch_customs_fee(direction:, shipment:)
    hub = direction == "export" ? shipment.origin_hub : shipment.destination_hub
    hub.get_customs(
      cargo_key(shipment: shipment),
      shipment.mode_of_transport,
      direction,
      shipment.trip.tenant_vehicle_id,
      shipment.destination_hub_id
    )
  end

  def customs_fee_result(shipment:)
    pricing_tools = OfferCalculator::PricingTools.new(shipment: shipment, user: shipment.user)
    currency = Users::Settings.find_by(user: shipment.user)&.currency || default_currency(user: shipment.user)
    total_fees = {total: {value: 0, currency: currency}}
    customs_fee = {total: total_fees}
    customs_fee = customs_fee_direction(
      customs_fee: customs_fee,
      direction: "export",
      pricing_tools: pricing_tools,
      shipment: shipment
    )
    customs_fee_direction(
      customs_fee: customs_fee,
      direction: "import",
      pricing_tools: pricing_tools,
      shipment: shipment
    )
  end

  def customs_fee_direction(shipment:, customs_fee:, direction:, pricing_tools:)
    fees = build_customs_fee_direction(pricing_tools: pricing_tools, shipment: shipment, direction: direction)
    customs_fee[:total][:total][:value] += fees.dig("total", "value") if fees.present?

    customs_fee[direction] = fees if fees.present?
    customs_fee
  end

  def default_currency(user:)
    OrganizationManager::ScopeService.new(
      target: user,
      organization: current_organization
    ).fetch(:default_currency)
  end

  def build_customs_fee_direction(pricing_tools:, shipment:, direction:)
    customs_fee = fetch_customs_fee(direction: direction, shipment: shipment)
    return {} if customs_fee.blank?

    pricing_tools.calc_addon_charges(
      charge: customs_fee["fees"],
      cargos: shipment.cargo_units.presence || [shipment.aggregated_cargo],
      user: shipment.user,
      mode_of_transport: shipment.mode_of_transport
    )
  end

  def cargo_key(shipment:)
    shipment.cargo_classes.first
  end

  def shipment_addons(shipment:)
    Addon.prepare_addons(
      shipment.origin_hub,
      shipment.destination_hub,
      cargo_key(shipment: shipment),
      shipment.trip.tenant_vehicle_id,
      shipment.mode_of_transport,
      shipment.cargo_units.presence || [shipment.aggregated_cargo],
      shipment.user
    )
  end

  def shipment_hubs_response(shipment:)
    {
      startHub: {data: shipment.origin_hub, address: shipment.origin_hub.nexus},
      endHub: {data: shipment.destination_hub, address: shipment.destination_hub.nexus}
    }
  end

  def choose_offer(params, current_user)
    raise ApplicationError::NotLoggedIn if current_user.blank?

    shipment = shipment_from_params(params: params)
    shipment = update_shipment_for_chosen_offer(shipment: shipment, params: params, current_user: current_user)
    copy_charge_breakdowns(shipment, params[:schedule][:charge_trip_id], params[:schedule]["trip_id"])

    {
      shipment: choose_offer_shipment_response(shipment: shipment),
      hubs: shipment_hubs_response(shipment: shipment),
      userLocations: user_addresses(user: current_user),
      schedule: params[:schedule].as_json,
      dangerousGoods: shipment.cargo_units.exists?(dangerous_goods: true),
      documents: shipment_documents(shipment: shipment),
      containers: shipment.containers,
      cargoItems: shipment.cargo_items,
      customs: customs_fee_result(shipment: shipment),
      addons: shipment_addons(shipment: shipment),
      addresses: choose_offer_address_response(shipment: shipment)
    }
  end

  def shipment_from_params(params:)
    shipment = Shipment.find_by(id: params[:shipment_id] || params[:id])
    raise ApplicationError::ShipmentNotFound if shipment.blank?

    shipment
  end

  def choose_offer_address_response(shipment:)
    origin = shipment.has_pre_carriage ? shipment.pickup_address : shipment.origin_nexus
    destination = shipment.has_on_carriage ? shipment.delivery_address : shipment.destination_nexus
    {
      origin: origin.try(:to_custom_hash),
      destination: destination.try(:to_custom_hash)
    }
  end

  def choose_offer_shipment_response(shipment:)
    options = {
      methods: %i[mode_of_transport service_level vessel_name carrier voyage_code],
      include: [{destination_nexus: {}}, {origin_nexus: {}}, {destination_hub: {}}, {origin_hub: {}}]
    }
    shipment.as_json(options).merge(
      selected_offer: shipment.selected_offer(Pdf::HiddenValueService.new(user: shipment.user).hide_total_args),
      pickup_address: shipment.pickup_address_with_country,
      delivery_address: shipment.delivery_address_with_country
    )
  end

  def search_contacts(contact_params, current_user)
    contact_email = contact_params["email"]
    existing_contact = Contact.where(user: current_user, email: contact_email).first
    existing_contact || Contact.create(contact_params.merge(user: current_user))
  end

  def reuse_cargo_units(shipment, cargo_units)
    cargo_units.each do |cargo_unit|
      cargo_json = cargo_unit.clone.as_json
      cargo_json.delete("id")
      cargo_json.delete("shipment_id")
      shipment.cargo_units.create!(cargo_json)
    end
  end

  def reuse_contacts(old_shipment, new_shipment)
    old_shipment.shipment_contacts.each do |old_contact|
      new_contact_json = old_contact.clone.as_json
      new_contact_json.delete("id")
      new_contact_json.delete("shipment_id")
      new_shipment.shipment_contacts.create!(new_contact_json)
    end
  end

  def view_more_schedules(trip_id, delta)
    trip = Trip.find(trip_id)
    trips = if delta.to_i.positive?
      trip.later_trips
    else
      trip.earlier_trips.sort_by(&:start_date)
    end
    final_results = false

    trips = trip.last_trips.sort_by(&:start_date) if trips.empty? && delta.to_i.positive?

    final_results = true if (trips.length < 5 || trips.empty?) && delta.to_i.positive?
    if (trips.length < 5 || trips.empty?) && !delta.to_i.positive?
      trips = trip.earliest_trips.sort_by(&:start_date)
    end

    {
      schedules: OfferCalculator::Schedule.from_trips(trips),
      itinerary_id: trip.itinerary_id,
      tenant_vehicle_id: trip.tenant_vehicle_id,
      finalResults: final_results
    }
  end

  def save_pdf_quotes(shipment, organization, schedules)
    tender_ids = schedules.map { |sched| sched.dig("meta", "tender_id") }
    tenders = Quotations::Tender.where(id: tender_ids)
    quotation = tenders.first.quotation
    send_on_download = ::OrganizationManager::ScopeService.new(
      target: shipment.user,
      organization: shipment.organization
    ).fetch(:send_email_on_quote_download)
    QuoteMailer.new_quotation_admin_email(quotation: quotation, shipment: shipment).deliver_later if send_on_download
    Pdf::Quotation::Client.new(
      quotation: quotation,
      tender_ids: tenders.ids
    ).file
  end

  def save_and_send_quotes(shipment, schedules, email)
    quotations_quotation = quotations_quotation(shipment: shipment)
    tender_ids = schedules.map { |sched| sched.dig("meta", "tender_id") }
    QuoteMailer.new_quotation_email(
      shipment: shipment,
      tender_ids: tender_ids,
      quotation: quotations_quotation,
      email: email
    ).deliver_later
    send_on_quote = ::OrganizationManager::ScopeService.new(
      target: shipment.user,
      organization: shipment.organization
    ).fetch(:send_email_on_quote_email)
    if send_on_quote
      QuoteMailer.new_quotation_admin_email(
        quotation: quotations_quotation,
        shipment: shipment
      ).deliver_later
    end
  end

  def quotations_quotation(shipment:)
    tender = shipment.charge_breakdowns.first.tender
    Quotations::Quotation.find(tender.quotation_id)
  end

  def tenant_notification_email(user, shipment)
    ShipmentMailer.tenant_notification(user, shipment).deliver_later
  end

  def shipper_notification_email(user, shipment)
    ShipmentMailer.shipper_notification(user, shipment).deliver_later
  end

  def shipper_welcome_email(user)
    no_welcome_content = Legacy::Content.where(organization_id: user.organization_id, component: "WelcomeMail").empty?
    WelcomeMailer.welcome_email(user).deliver_later unless no_welcome_content
  end

  def shipper_confirmation_email(user, shipment)
    ShipmentMailer.shipper_confirmation(
      user,
      shipment
    ).deliver_later
  end

  def get_hs_code_hash(codes)
    resp = get_items_by_key_values(false, "hsCodes", "_id", codes)
    results = {}

    resp.each do |hs|
      results[hs["_id"]] = hs
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

  def handle_extra_charges(shipment:, shipment_data:)
    charge_breakdown = shipment.charge_breakdowns.selected
    tender = charge_breakdown.tender
    existing_insurance_charge = charge_breakdown.charge("insurance")
    existing_insurance_charge&.destroy
    tender.line_items.where(section: "insurance_section").destroy_all
    existing_customs_charge = charge_breakdown.charge("customs")
    existing_customs_charge&.destroy
    tender.line_items.where(section: "customs_section").destroy_all
    existing_addons_charge = charge_breakdown.charge("addons")
    existing_addons_charge&.destroy
    tender.line_items.where(section: "addons_section").destroy_all
    grand_total_charge_category = Legacy::ChargeCategory.from_code(
      code: "grand_total", name: "Grand Total", organization_id: shipment.organization_id
    )
    if shipment_data[:insurance][:isSelected]
      insurance_parent_charge = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: "insurance", organization_id: shipment.organization_id
        ),
        charge_category: grand_total_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment[:total_goods_value]["currency"], value: shipment_data[:insurance][:val]
        ),
        parent: charge_breakdown.charge("grand_total")
      )
      insurance_charge = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: "freight_insurance", organization_id: shipment.organization_id
        ),
        charge_category: insurance_parent_charge.children_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment[:total_goods_value]["currency"], value: shipment_data[:insurance][:val]
        ),
        parent: insurance_parent_charge
      )
      tender.line_items.create(
        section: "insurance_section",
        charge_category: insurance_charge.children_charge_category,
        original_amount: insurance_charge.price.money,
        amount: insurance_charge.price.money
      )
    end

    if shipment_data[:customs][:total][:val].to_d.positive? || shipment_data[:customs][:total][:hasUnknown]
      customs_parent_charge = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: "customs", organization_id: shipment.organization_id
        ),
        charge_category: grand_total_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment_data[:customs][:total][:currency],
          value: shipment_data[:customs][:total][:val]
        ),
        parent: charge_breakdown.charge("grand_total")
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
          code: "addons", organization_id: shipment.organization_id
        ),
        charge_category: grand_total_charge_category,
        charge_breakdown: charge_breakdown,
        price: Legacy::Price.create(
          currency: shipment_data[:addons][:customs_export_paper][:currency],
          value: shipment_data[:addons][:customs_export_paper][:value]
        ),
        parent: charge_breakdown.charge("grand_total")
      )
      customs_export_paper = Legacy::Charge.create(
        children_charge_category: Legacy::ChargeCategory.from_code(
          code: "customs_export_paper", organization_id: shipment.organization_id
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
    charge_breakdown.charge("grand_total").update_price!
  end
end
