# frozen_string_literal: true

require 'active_storage'

class PdfService
  include ApplicationHelper
  BreezyError = Class.new(StandardError)

  attr_reader :tenant, :user, :pdf, :url, :sandbox

  def initialize(tenant:, user:, sandbox: nil)
    @tenant = tenant
    @user   = user
    @sandbox = sandbox
  end

  def generate_pdf(
    template:,
    name:,
    shipment: nil,
    shipments: nil,
    quotes: nil,
    quotation: nil,
    load_type: nil,
    cargo_units: {},
    note_remarks: nil,
    selected_offer: nil
  )
    logo = Base64.encode64(Net::HTTP.get(URI(tenant.theme['logoLarge'])))
    pdf = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      margin: { top: 10, bottom: 5, left: 8, right: 8 },
      logo: logo,
      remarks: Remark.where(tenant_id: tenant.id, sandbox_id: sandbox&.id).order(order: :asc),
      template: template,
      name: name,
      shipment: shipment,
      selected_offer: selected_offer,
      shipments: shipments,
      quotes: quotes,
      quotation: quotation,
      load_type: load_type,
      note_remarks: note_remarks,
      cargo_units: cargo_units
    )
    pdf.generate
  rescue Errno::ECONNRESET => e
    Raven.capture_exception(e)
    nil
  rescue PdfHandler::BreezyError
    nil
  end

  def generate_shipment_pdf(shipment:, load_type:)
    generate_pdf(
      template: 'shipments/pdfs/shipment_recap.pdf.html.erb',
      shipment: shipment,
      shipments: [shipment],
      selected_offer: shipment.selected_offer(HiddenValueService.new(user: shipment.user).hide_total_args),
      load_type: load_type,
      quotes: quotes_with_trip_id(quotation: nil, shipments: [shipment]),
      name: 'shipment_recap',
      cargo_units: { shipment.id => shipment.cargo_units }
    )
  end

  def generate_quote_pdf(shipment:, shipments:, quotes:, quotation:, note_remarks:)
    generate_pdf(
      template: 'shipments/pdfs/quotations.pdf.erb',
      shipment: shipment,
      shipments: shipments,
      quotes: quotes,
      quotation: quotation,
      name: 'quotation',
      note_remarks: note_remarks,
      cargo_units: shipments.each_with_object({}) do |ship, hash|
        hash[ship.id] = ship.cargo_units
      end
    )
  end

  def admin_quotation(quotation: nil, shipment: nil)
    existing_document = existing_document(quotation: quotation, shipment: shipment, type: 'quotation')
    return existing_document if existing_document

    object = quotation || shipment
    shipments = quotation ? quotation.shipments : [shipment]
    shipment = quotation ? Legacy::Shipment.find(quotation.original_shipment_id) : shipment
    quotation = quotation
    quotes = quotes_with_trip_id(quotation: quotation, shipments: shipments, admin: true)
    note_remarks = get_note_remarks(quotes.first['trip_id'])
    file = generate_quote_pdf(
      shipment: shipment,
      shipments: shipments,
      quotes: quotes,
      quotation: quotation,
      note_remarks: note_remarks
    )
    return nil if file.nil?

    create_file(object: object, shipments: shipments, file: file, user: user, sandbox: sandbox)
  end

  def existing_document(quotation: nil, shipment: nil, type:)
    object = quotation || shipment
    document = if quotation.present?
                 Legacy::File.find_by(
                   tenant_id: tenant.id,
                   user: user,
                   quotation: quotation,
                   doc_type: type,
                   sandbox_id: sandbox&.id
                 )
               else
                 Legacy::File.find_by(
                   tenant_id: tenant.id,
                   user: user,
                   shipment: shipment,
                   doc_type: type,
                   sandbox_id: sandbox&.id
                 )
               end

    return unless document.present? && (object.updated_at < document.updated_at && document.file.attached?)

    document
  end

  def hidden_value_args(admin: false)
    value_service = HiddenValueService.new(user: user)
    if admin
      value_service.admin_args
    else
      value_service.hide_total_args
    end
  end

  def quotes_with_trip_id(quotation:, shipments:, admin: false)
    hidden_args = hidden_value_args(admin: admin)
    shipments.flat_map do |shipment|
      trip = shipment.trip
      offers = if quotation.present?
                 [shipment.selected_offer(hidden_args)]
               else
                 shipment.charge_breakdowns.map { |charge_breakdown| charge_breakdown.to_nested_hash(hidden_args) }
               end
      offers.map do |offer|
        trip = Trip.find(offer['trip_id']) if trip.nil?
        origin_hub = trip.itinerary.first_stop.hub
        destination_hub = trip.itinerary.last_stop.hub
        offer.merge(
          offer_merge_data(
            trip: trip,
            shipment: shipment,
            origin_hub: origin_hub,
            destination_hub: destination_hub
          )
        ).deep_stringify_keys
      end
    end
  end

  def quotation_pdf(quotation:)
    existing_document = existing_document(quotation: quotation, type: 'quotation')
    return existing_document if existing_document

    quotes = quotes_with_trip_id(quotation: quotation, shipments: quotation.shipments)
    shipment = Legacy::Shipment.find(quotation.original_shipment_id)
    note_remarks = get_note_remarks(quotes.first['trip_id'])
    file = generate_quote_pdf(
      shipment: shipment,
      shipments: quotation.shipments,
      quotes: quotes,
      quotation: quotation,
      note_remarks: note_remarks
    )
    return nil if file.nil?

    create_file(object: quotation, file: file, user: user, sandbox: sandbox)
  end

  def shipment_pdf(shipment:)
    existing_document = existing_document(shipment: shipment, type: 'shipment_recap')
    return existing_document if existing_document

    file = generate_shipment_pdf(
      shipment: shipment,
      load_type: load_type_plural(shipment: shipment)
    )
    return nil if file.nil?

    create_file(object: shipment, file: file, user: user, sandbox: sandbox)
  end

  def load_type_plural(shipment:)
    cargo_count = shipment.cargo_units.count
    if shipment.load_type == 'cargo_item'
      "Cargo Item#{cargo_count > 1 ? 's' : ''}"
    else
      "Container#{cargo_count > 1 ? 's' : ''}"
    end
  end

  private

  def get_note_remarks(trip_id)
    trip = Trip.find(trip_id)
    start_date = trip.start_date || OfferCalculator::Schedule.quote_trip_start_date
    end_date = trip.end_date || OfferCalculator::Schedule.quote_trip_end_date
    pricing_ids = Pricings::Pricing.where(
      itinerary_id: trip.itinerary_id,
      tenant_vehicle_id: trip.tenant_vehicle_id
    ).for_dates(start_date, end_date).ids
    note_association = Note.where(tenant_id: tenant.id, remarks: true)
    note_association.where(pricings_pricing_id: pricing_ids)
                    .or(note_association.where(target: tenant))
                    .distinct
                    .pluck(:body)
  end

  def offer_merge_data(trip:, shipment:, origin_hub:, destination_hub:)
    {
      trip_id: trip.id,
      origin: origin_hub.name,
      destination: destination_hub.name,
      origin_free_out: origin_hub.free_out,
      destination_free_out: destination_hub.free_out,
      pickup_address: shipment.pickup_address&.full_address,
      delivery_address: shipment.delivery_address&.full_address,
      mode_of_transport: trip.itinerary.mode_of_transport,
      valid_until: shipment.valid_until(trip),
      imc_reference: shipment.imc_reference,
      shipment_id: shipment.id,
      load_type: shipment.load_type,
      carrier: trip.tenant_vehicle.carrier&.name,
      service_level: trip.tenant_vehicle.name,
      transshipment: transshipment_note(trip: trip)
    }
  end

  def transshipment_note(trip:)
    Legacy::Note.find_by(
      transshipment: true,
      pricings_pricing_id: ::Pricings::Pricing.where(
        itinerary_id: trip.itinerary_id, tenant_vehicle_id: trip.tenant_vehicle_id
      ).ids
    )&.body
  end

  def create_file(object:, file:, user:, shipments: [], sandbox: nil)
    args = {
      text: file_text(object: object, shipments: shipments),
      doc_type: doc_type(object: object),
      user: user,
      tenant: user.tenant,
      sandbox_id: sandbox&.id,
      file: {
        io: StringIO.new(file),
        filename: "#{file_text(object: object, shipments: shipments)}.pdf",
        content_type: 'application/pdf'
      }
    }
    if object.is_a? Legacy::Quotation
      args[:quotation] = object
    else
      args[:shipment] = object
    end
    Legacy::File.create!(args)
  end

  def file_text(object:, shipments: [])
    if object.is_a? Legacy::Quotation
      "quotation_#{object.shipments.pluck(:imc_reference).join(',')}"
    elsif object.is_a?(Legacy::Shipment) && shipments.present?
      "quotation_#{shipments.pluck(:imc_reference).join(',')}"
    else
      "shipment_#{object.imc_reference}"
    end
  end

  def doc_type(object:)
    if object.is_a? Legacy::Quotation
      'quotation'
    else
      'shipment_recap'
    end
  end
end
