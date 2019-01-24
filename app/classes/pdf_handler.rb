# frozen_string_literal: true

class PdfHandler
  BreezyError = Class.new(StandardError)

  attr_reader :name, :full_name, :pdf, :url, :path

  def initialize(args = {})
    args.symbolize_keys!

    @layout                = args[:layout]
    @template              = args[:template]
    @footer                = args[:footer]
    @margin                = args[:margin]
    @shipment              = args[:shipment]
    @shipments             = args[:shipments] || []
    @name                  = args[:name]
    @quotes                = args[:quotes]
    @quotation             = args[:quotation]
    @logo                  = args[:logo]
    @load_type             = args[:load_type]
    @remarks               = args[:remarks]
    @hide_cargo_sub_totals = false
    @content               = {}

    @cargo_data = {
      vol: {},
      kg: {},
      chargeable_weight: {}
    }

    @shipments << @shipment if @shipments.empty?
    @shipments.each do |s|
      calculate_cargo_data(s)
    end
    @content = Content.get_component('QuotePdf', @shipment.tenant_id) if @name == 'quotation'

    @full_name = "#{@name}_#{@shipment.imc_reference}.pdf"
  end

  def calculate_cargo_data(shipment)
    kg = if shipment.aggregated_cargo
           shipment.aggregated_cargo.weight.to_f
         else
           shipment.cargo_units.inject(0) do |sum, hash|
             sum + hash[:quantity].to_f * hash[:payload_in_kg].to_f
           end
         end
    chargeable_weight = {}
    chargeable_weight[:cargo] = if shipment.aggregated_cargo
                                  shipment.aggregated_cargo.weight.to_f
                                else
                                  shipment.cargo_units.inject(0) do |sum, hash|
                                    sum + hash[:quantity].to_f * hash[:chargeable_weight].to_f
                                  end
                                end
    chargeable_weight[:trucking_pre] =
      @shipment.trucking.dig('pre_carriage', 'chargeable_weight')
    chargeable_weight[:trucking_on] =
      @shipment.trucking.dig('on_carriage', 'chargeable_weight')
    vol = if shipment.aggregated_cargo
            shipment.aggregated_cargo.volume.to_f
          else
            shipment.cargo_units.inject(0) do |sum, hash|
              sum + (hash[:quantity].to_f *
                hash[:dimension_x].to_f *
                hash[:dimension_y].to_f *
                hash[:dimension_z].to_f / 1_000_000)
            end
          end
    @cargo_data[:kg][shipment.id] = kg
    @cargo_data[:chargeable_weight][shipment.id] = chargeable_weight
    @cargo_data[:vol][shipment.id] = vol
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
        notes: @shipment.route_notes,
        hide_cargo_sub_totals: @hide_cargo_sub_totals,
        content: @content
      }
    )
    response = BreezyPDFLite::RenderRequest.new(
      doc_erb.render
    ).submit

    raise BreezyError, response.body if response.code.to_i != 201

    response.body
  end
end
