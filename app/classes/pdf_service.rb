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

  def generate_pdf(shipment:, quotation:, shipments:, quotes:)
    logo = Base64.encode64(Net::HTTP.get(URI(tenant.theme['logoLarge'])))
    pdf = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      template: 'shipments/pdfs/quotations.pdf.erb',
      margin: { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: shipment,
      shipments: shipments,
      quotes: quotes,
      logo: logo,
      quotation: quotation,
      name: 'quotation',
      remarks: Remark.where(tenant_id: tenant.id, sandbox: sandbox).order(order: :asc)
    )
    pdf.generate
  rescue Errno::ECONNRESET => e
    Raven.capture_exception(e)
    nil
  rescue PdfHandler::BreezyError
    nil
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
    return existing_document if existing_document&.file.present?

    shipments = quotation ? quotation.shipments : [shipment]
    shipment = quotation ? Shipment.find(quotation.original_shipment_id) : shipment
    quotation = quotation
    quotes = quotes_with_trip_id(quotation, shipments)
    file = generate_pdf(
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

  def quotation_pdf(quotation:)
    existing_document = Document.find_by(tenant_id: tenant.id, user: user, quotation: quotation, doc_type: 'quotation', sandbox: sandbox)
    return existing_document if existing_document&.file.present?

    quotes = quotation.shipments.map { |s| s.selected_offer.merge(trip_id: s.trip_id).deep_stringify_keys }
    shipment = Shipment.find(quotation.original_shipment_id)
    file = generate_pdf(
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
end
