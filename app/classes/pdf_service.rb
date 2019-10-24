# frozen_string_literal: true

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
    load_type: nil
  )
    logo = Base64.encode64(Net::HTTP.get(URI(tenant.theme['logoLarge'])))
    pdf = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      margin: { top: 10, bottom: 5, left: 8, right: 8 },
      logo: logo,
      remarks: Remark.where(tenant_id: tenant.id, sandbox: sandbox).order(order: :asc),
      template: template,
      name: name,
      shipment: shipment,
      shipments: shipments,
      quotes: quotes,
      quotation: quotation,
      load_type: load_type
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
      name: 'shipment_recap'
    )
  end

  def generate_quote_pdf(shipment:, shipments:, quotes:, quotation:)
    generate_pdf(
      template: 'shipments/pdfs/quotations.pdf.erb',
      shipment: shipment,
      shipments: shipments,
      quotes: quotes,
      quotation: quotation,
      name: 'quotation'
    )
  end

  def quotes_with_trip_id(quotation, shipments)
    if quotation
      shipments.map { |s| s.selected_offer.merge(trip_id: s.trip_id).deep_stringify_keys }
    else
      shipments.first.charge_breakdowns.map { |cb| cb.to_nested_hash.merge(trip_id: cb.trip_id).deep_stringify_keys }
    end
  end

  def admin_quotation(quotation: nil, shipment: nil)
    existing_document = if quotation.present?
                          Document.find_by(tenant_id: tenant.id, user: user, quotation: quotation, doc_type: 'quotation', sandbox: sandbox)
                        else
                          Document.find_by(tenant_id: tenant.id, user: user, shipment: shipment, doc_type: 'quotation', sandbox: sandbox)
    end
    return existing_document if needs_update?(object: quotation || shipment, document: existing_document)

    shipments = quotation ? quotation.shipments : [shipment]
    shipment = quotation ? Shipment.find(quotation.original_shipment_id) : shipment
    quotation = quotation
    quotes = quotes_with_trip_id(quotation, shipments)
    file = generate_quote_pdf(
      shipment: shipment,
      shipments: shipments,
      quotes: quotes,
      quotation: quotation
    )
    return nil if file.nil?

    Document.create!(
      shipment: shipment,
      text: "quotation_#{shipments.pluck(:imc_reference).join(',')}",
      doc_type: 'quotation',
      user: user,
      tenant: tenant,
      sandbox: sandbox,
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

  def quotation_pdf(quotation:)
    existing_document = Document.find_by(tenant_id: tenant.id, user: user, quotation: quotation, doc_type: 'quotation', sandbox: sandbox)
    return existing_document if needs_update?(object: quotation, document: existing_document)

    quotes = quotation.shipments.map { |s| s.selected_offer.merge(trip_id: s.trip_id).deep_stringify_keys }
    shipment = Shipment.find(quotation.original_shipment_id)
    file = generate_quote_pdf(
      shipment: shipment,
      shipments: quotation.shipments,
      quotes: quotes,
      quotation: quotation
    )
    return nil if file.nil?

    Document.create!(
      quotation: quotation,
      text: "quotation_#{quotation.shipments.pluck(:imc_reference).join(',')}",
      doc_type: 'quotation',
      user: user,
      tenant: tenant,
      sandbox: sandbox,
      file: {
        io: StringIO.new(file),
        filename: "quotation_#{quotation.shipments.pluck(:imc_reference).join(',')}.pdf",
        content_type: 'application/pdf'
      }
    )
  end

  def shipment_pdf(shipment:)
    existing_document = Document.find_by(tenant_id: tenant.id, user: user, shipment: shipment, doc_type: 'shipment_recap', sandbox: sandbox)
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

    Document.create!(
      shipment: shipment,
      text: "shipment_#{shipment.imc_reference}",
      doc_type: 'shipment_recap',
      user: user,
      tenant: tenant,
      sandbox: sandbox,
      file: {
        io: StringIO.new(file),
        filename: "shipment_#{shipment.imc_reference}.pdf",
        content_type: 'application/pdf'
      }
    )
  end
end
