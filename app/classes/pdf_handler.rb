# frozen_string_literal: true

class PdfHandler
  BreezyError = Class.new(StandardError)

  attr_reader :name, :full_name, :pdf, :url, :path

  def initialize(args = {})
    args.symbolize_keys!

    @layout     = args[:layout]
    @template   = args[:template]
    @footer     = args[:footer]
    @margin     = args[:margin]
    @shipment   = args[:shipment]
    @shipments  = args[:shipments] || []
    @name       = args[:name]
    @quotes     = args[:quotes]
    @quotation  = args[:quotation]
    @logo       = args[:logo]
    @load_type  = args[:load_type]
    @remarks    = args[:remarks]
    @cargo_data = {
      vol: {},
      kg: {}
    }
    if @shipments.empty?
      @shipments << @shipment
    end
    @shipments.each do |s|
      @cargo_data[:kg][s.id] =  if s.aggregated_cargo
                                  s.aggregated_cargo.weight.to_f
                                else
                                  s.cargo_units.inject(0) { |sum, hash| sum + hash[:quantity].to_f * hash[:payload_in_kg].to_f }
                                end
      @cargo_data[:vol][s.id] = if s.aggregated_cargo
                                  s.aggregated_cargo.volume.to_f
                                else
                                  s.cargo_units.inject(0) do |sum, hash|
                                    sum + (hash[:quantity].to_f * hash[:dimension_x].to_f * hash[:dimension_y].to_f * hash[:dimension_z].to_f / 1_000_000)
                                  end
                                end
    end

    @full_name = "#{@name}_#{@shipment.imc_reference}.pdf"
  end

  def itinerary_notes(shipment)
    shipment.itinerary&.notes || []
  end

  def origin_hub_notes(shipment)
    shipment.origin_hub&.notes || []
  end

  def destination_hub_notes(shipment)
    shipment.destination_hub&.notes || []
  end

  def hub_notes(shipment)
    [origin_hub_notes(shipment), destination_hub_notes(shipment)].flatten
  end

  def on_carriage_notes(shipment)
    Note.where(trucking_pricing_id: shipment.trucking.dig('on_carriage', 'address_id'))
  end

  def pre_carriage_notes(shipment)
    Note.where(trucking_pricing_id: shipment.trucking.dig('pre_carriage', 'address_id'))
  end

  def trucking_notes(shipment)
    [on_carriage_notes(shipment), pre_carriage_notes(shipment)].flatten
  end

  def notes(shipment)
    [itinerary_notes(shipment), hub_notes(shipment), trucking_notes(shipment)].flatten.uniq
  end

  def generate
    doc_erb = ErbTemplate.new(
      layout: @layout,
      template: @template,
      locals: {
        shipment: @shipment,
        shipments: @shipments,
        quotes: @quotes,
        logo: @logo,
        load_type: @load_type,
        remarks: @remarks,
        tenant: @shipment.tenant,
        cargo_data: @cargo_data,
        notes: notes(@shipment)
      }
    )
    response = BreezyPDFLite::RenderRequest.new(
      doc_erb.render
    ).submit

    raise BreezyError, response.body if response.code.to_i != 201

    response.body
  end
end
