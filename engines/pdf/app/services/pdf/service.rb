# frozen_string_literal: true

require 'active_storage'
module Pdf
  class Service < Pdf::Base
    attr_reader :organization, :user, :pdf, :url

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
      logo = Base64.encode64(@theme.large_logo.download) if @theme.large_logo.attached?

      pdf = Pdf::Handler.new(
        layout: 'pdfs/simple.pdf.html.erb',
        margin: { top: 10, bottom: 5, left: 8, right: 8 },
        logo: logo,
        remarks: Legacy::Remark.where(organization: organization).order(order: :asc),
        template: template,
        name: name,
        shipment: shipment,
        selected_offer: selected_offer,
        shipments: shipments,
        quotes: quotes,
        quotation: quotation,
        load_type: load_type,
        note_remarks: note_remarks,
        cargo_units: cargo_units,
        organization: organization
      )
      pdf.generate
    rescue Errno::ECONNRESET => e
      Raven.capture_exception(e)
      nil
    end

    def generate_shipment_pdf(shipment:, load_type:)
      generate_pdf(
        template: 'shipments/pdfs/shipment_recap.pdf.html.erb',
        shipment: shipment,
        shipments: [shipment],
        selected_offer: shipment.selected_offer(Pdf::HiddenValueService.new(user: shipment.user).hide_total_args),
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

    def admin_quotation(shipment:, quotation: nil, pdf_tenders: nil)
      if quotation.is_a?(Legacy::Quotation)
        quotation = Quotations::Quotation.find_by(legacy_shipment_id: shipment.id)
        pdf_tenders = tenders(quotation: quotation, shipment: shipment)
      end

      existing_document = existing_document(shipment: shipment, type: 'quotation')
      return existing_document if existing_document

      note_remarks = get_note_remarks(pdf_tenders.first['trip_id'])
      file = generate_quote_pdf(
        shipment: shipment,
        shipments: [shipment],
        quotes: pdf_tenders,
        quotation: quotation,
        note_remarks: note_remarks
      )
      return nil if file.nil?

      create_file(object: shipment, shipments: [shipment], file: file, user: user)
    end

    def legacy_admin_quotation(quotation:, shipment:)
      existing_document = existing_document(quotation: quotation, shipment: shipment, type: "quotation")
      return existing_document if existing_document

      object = quotation || shipment
      shipments = quotation ? quotation.shipments : [shipment]
      shipment = quotation ? Legacy::Shipment.find(quotation.original_shipment_id) : shipment
      quotes = quotes_with_trip_id(quotation: quotation, shipments: shipments, admin: true)

      note_remarks = get_note_remarks(quotes.first["trip_id"])
      file = generate_quote_pdf(
        shipment: shipment,
        shipments: shipments,
        quotes: quotes,
        quotation: quotation,
        note_remarks: note_remarks
      )
      return nil if file.nil?

      create_file(object: object, shipments: shipments, file: file, user: user)
    end

    def wheelhouse_quotation(shipment:, tender_ids:)
      object = shipment
      shipments = [shipment]
      quotes = quotes_with_trip_id(
        quotation: nil,
        shipments: shipments,
        admin: true,
        tender_ids: tender_ids
      )
      note_remarks = get_note_remarks(quotes.dig(0, 'trip_id'))
      file = generate_quote_pdf(
        shipment: shipment,
        shipments: shipments,
        quotes: quotes,
        quotation: nil,
        note_remarks: note_remarks
      )
      return nil if file.nil?

      create_file(object: object, shipments: shipments, file: file, user: user)
    end

    def existing_document(type:, quotation: nil, shipment: nil)
      object = quotation || shipment
      document = if quotation.present?
                   Legacy::File.find_by(
                     organization: organization,
                     user: user,
                     quotation: quotation,
                     doc_type: type
                   )
                 else
                   Legacy::File.find_by(
                     organization: organization,
                     user: user,
                     shipment: shipment,
                     doc_type: type
                   )
                 end

      return unless document.present? && (object.updated_at < document.updated_at && document.file.attached?)

      document
    end

    def hidden_value_args(admin: false)
      value_service = Pdf::HiddenValueService.new(user: user)
      if admin
        value_service.admin_args
      else
        value_service.hide_total_args
      end
    end

    def quotes_with_trip_id(quotation:, shipments:, admin: false, tender_ids: [])
      shipments.flat_map do |shipment|
        trip = shipment.trip
        charge_breakdowns = quotation.present? ? [shipment.charge_breakdowns.selected] : shipment.charge_breakdowns.to_a
        if tender_ids.present?
          charge_breakdowns = charge_breakdowns.select { |c_breakdown| tender_ids.include?(c_breakdown.tender_id) }
        end
        charge_breakdowns
          .flatten
          .map { |charge_breakdown|
          offer_manipulation_block(
            charge_breakdown: charge_breakdown,
            shipment: shipment,
            trip: trip,
            admin: admin
          )
        }
      end
    end

    def tenders(shipment:, quotation:, admin: false)
      quotation.tenders.map do |tender|
        breakdown = tender.charge_breakdown

        offer_manipulation_block(
          charge_breakdown: breakdown,
          shipment: shipment,
          trip: breakdown.trip,
          admin: admin
        )
      end
    end

    def offer_manipulation_block(charge_breakdown:, shipment:, trip: nil, admin: false)
      tender = charge_breakdown.tender
      offer_merge_data(tender: tender, shipment: shipment).merge(
        fees: ResultFormatter::FeeTableService.new(tender: tender, scope: scope, type: :pdf).perform,
        currency: tender.amount_currency
      ).deep_stringify_keys
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

      create_file(object: quotation, file: file, user: user)
    end

    def tenders_pdf(quotation:, shipment:, pdf_tenders:)
      existing_document = existing_document(shipment: shipment, type: 'quotation')
      return existing_document if existing_document

      note_remarks = get_note_remarks(pdf_tenders.first['trip_id'])
      file = generate_quote_pdf(
        shipment: shipment,
        shipments: [shipment],
        quotes: pdf_tenders,
        quotation: quotation,
        note_remarks: note_remarks
      )
      return nil if file.nil?

      create_file(object: shipment, file: file, user: user)
    end

    def shipment_pdf(shipment:)
      existing_document = existing_document(shipment: shipment, type: 'shipment_recap')
      return existing_document if existing_document

      file = generate_shipment_pdf(
        shipment: shipment,
        load_type: load_type_plural(shipment: shipment)
      )
      return nil if file.nil?

      create_file(object: shipment, file: file, user: user)
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
      return [] if trip_id.nil?

      trip = Legacy::Trip.find(trip_id)
      start_date = trip.start_date || OfferCalculator::Schedule.quote_trip_start_date
      end_date = trip.end_date || OfferCalculator::Schedule.quote_trip_end_date
      pricing_ids = Pricings::Pricing.where(
        itinerary_id: trip.itinerary_id,
        tenant_vehicle_id: trip.tenant_vehicle_id
      ).for_dates(start_date, end_date).ids
      note_association = Legacy::Note.where(organization: organization, remarks: true)
      note_association.where(pricings_pricing_id: pricing_ids)
                      .or(note_association.where(target: nil))
                      .distinct
                      .pluck(:body)
    end

    def offer_merge_data(tender:, shipment:)
      tender_merge_data(tender: tender)
        .merge(shipment_merge_data(shipment: shipment))
        .merge(trucking_information(tender: tender))
        .merge(routing_merge_data(tender: tender))
    end

    def tender_merge_data(tender:)
      {
        mode_of_transport: tender.mode_of_transport,
        valid_until: tender.charge_breakdown.valid_until,
        load_type: tender.load_type,
        carrier: tender.tenant_vehicle.carrier&.name&.upcase,
        service_level: tender.tenant_vehicle.name,
        total: tender.amount.format(symbol: tender.amount.currency.to_s + ' '),
        transshipment: tender.itinerary.transshipment,
        imc_reference: tender.imc_reference,
        transit_time: ::Legacy::TransitTime.find_by(
          tenant_vehicle: tender.tenant_vehicle,
          itinerary: tender.itinerary
        )&.duration
      }
    end

    def routing_merge_data(tender:)
      origin_hub = Legacy::HubDecorator.new(tender.origin_hub, context: {scope: scope})
      destination_hub = Legacy::HubDecorator.new(tender.destination_hub, context: {scope: scope})
      {
        trip_id: tender.charge_breakdown.trip_id,
        origin: origin_hub.name,
        destination: destination_hub.name,
        origin_free_out: origin_hub.free_out,
        destination_free_out: destination_hub.free_out
      }
    end

    def shipment_merge_data(shipment:)
      {
        shipment_id: shipment.id
      }
    end

    def trucking_information(tender:)
      {
        pre_carriage_service: carriage_service_string(tender: tender, carriage: 'pre'),
        on_carriage_service: carriage_service_string(tender: tender, carriage: 'on'),
        pickup_address: tender.pickup_address&.full_address,
        delivery_address: tender.delivery_address&.full_address
      }
    end

    def carriage_service_string(tender:, carriage:)
      voyage_info = scope.dig(:voyage_info)
      carrier_key = "#{carriage}_carriage_carrier"
      service_key = "#{carriage}_carriage_service"
      return '' if voyage_info.slice(service_key, carrier_key).values.none?

      service = carriage == 'pre' ? tender.pickup_tenant_vehicle : tender.delivery_tenant_vehicle
      operator = if voyage_info.slice(service_key, carrier_key).values.all?
        "#{service&.carrier&.name}(#{service&.name})"
      elsif voyage_info.dig(service_key)
        service&.name
      elsif voyage_info.dig(carrier_key)
        service&.carrier&.name
      else
        ''
      end
      "operated by #{operator}"
    end

    def create_file(object:, file:, user:, shipments: [])
      args = {
        text: file_text(object: object, shipments: shipments),
        doc_type: doc_type(object: object),
        user: user,
        organization: @organization,
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
end
