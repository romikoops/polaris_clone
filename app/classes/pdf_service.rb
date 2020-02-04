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
    note_remarks: nil
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
      load_type: load_type,
      quotes: quotes_with_trip_id(nil, [shipment]),
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
    existing_document = if quotation.present?
                          Legacy::Document.find_by(tenant_id: tenant.id, user: user, quotation: quotation, doc_type: 'quotation', sandbox_id: sandbox&.id)
                        else
                          Legacy::Document.find_by(tenant_id: tenant.id, user: user, shipment: shipment, doc_type: 'quotation', sandbox_id: sandbox&.id)
    end
    return existing_document if needs_update?(object: quotation || shipment, document: existing_document)

    shipments = quotation ? quotation.shipments : [shipment]
    shipment = quotation ? Legacy::Shipment.find(quotation.original_shipment_id) : shipment
    quotation = quotation
    quotes = quotes_with_trip_id(quotation, shipments)
    note_remarks = get_note_remarks(quotes.first['trip_id'])
    file = generate_quote_pdf(
      shipment: shipment,
      shipments: shipments,
      quotes: quotes,
      quotation: quotation,
      note_remarks: note_remarks
    )
    return nil if file.nil?

    Legacy::Document.create!(
      shipment: shipment,
      text: "quotation_#{shipments.pluck(:imc_reference).join(',')}",
      doc_type: 'quotation',
      user: user,
      tenant: tenant,
      sandbox_id: sandbox&.id,
      file: {
        io: StringIO.new(file),
        filename: "quotation_#{shipments.pluck(:imc_reference).join(',')}.pdf",
        content_type: 'application/pdf'
      }
    )
  end

  def needs_update?(object: , document:)
    document.present? && (object.updated_at < document.updated_at && document.file.present?)
  end

  def quotes_with_trip_id(quotation, shipments)
    shipments.flat_map do |shipment|
      trip = shipment.trip
      offers = quotation.present? ? [shipment.selected_offer] : shipment.charge_breakdowns.map(&:to_nested_hash)
      offers.map do |offer|
        trip = Trip.find(offer['trip_id']) if trip.nil?
        origin_hub = trip.itinerary.first_stop.hub
        destination_hub = trip.itinerary.last_stop.hub
        offer.merge(
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
          transshipment: Note.find_by(
            transshipment: true,
            pricings_pricing_id: ::Pricings::Pricing.where(itinerary_id: trip.itinerary_id, tenant_vehicle_id: trip.tenant_vehicle_id).ids
          )&.body
        ).deep_stringify_keys
      end
    end
  end

  def quotation_pdf(quotation:)
    existing_document = Legacy::Document.find_by(tenant_id: tenant.id, user: user, quotation: quotation, doc_type: 'quotation', sandbox_id: sandbox&.id)
    return existing_document if needs_update?(object: quotation, document: existing_document)

    quotes = quotes_with_trip_id(quotation, quotation.shipments)
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

    Legacy::Document.create!(
      quotation: quotation,
      text: "quotation_#{quotation.shipments.pluck(:imc_reference).join(',')}",
      doc_type: 'quotation',
      user: user,
      tenant: tenant,
      sandbox_id: sandbox&.id,
      file: {
        io: StringIO.new(file),
        filename: "quotation_#{quotation.shipments.pluck(:imc_reference).join(',')}.pdf",
        content_type: 'application/pdf'
      }
    )
  end

  def shipment_pdf(shipment:)
    existing_document = Legacy::Document.find_by(tenant_id: tenant.id, user: user, shipment: shipment, doc_type: 'shipment_recap', sandbox_id: sandbox&.id)
    return existing_document if existing_document&.file.present?

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

    file = generate_shipment_pdf(
      shipment: shipment,
      load_type: load_type
    )
    return nil if file.nil?

    Legacy::Document.create!(
      shipment: shipment,
      text: "shipment_#{shipment.imc_reference}",
      doc_type: 'shipment_recap',
      user: user,
      tenant: tenant,
      sandbox_id: sandbox&.id,
      file: {
        io: StringIO.new(file),
        filename: "shipment_#{shipment.imc_reference}.pdf",
        content_type: 'application/pdf'
      }
    )
  end

  private

  def get_note_remarks(trip_id)
    trip = Trip.find(trip_id)
    start_date = trip.start_date || OfferCalculator::Schedule::QUOTE_TRIP_START_DATE
    end_date = trip.end_date || OfferCalculator::Schedule::QUOTE_TRIP_END_DATE
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
end
