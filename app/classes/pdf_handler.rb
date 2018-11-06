# frozen_string_literal: true

class PdfHandler
  attr_reader :name, :full_name, :pdf, :url, :path

  def initialize(args = {})
    args.symbolize_keys!

    @layout     = args[:layout]
    @template   = args[:template]
    @footer     = args[:footer]
    @margin     = args[:margin]
    @shipment   = args[:shipment]
    @shipments  = args[:shipments]
    @name       = args[:name]
    @quotes     = args[:quotes]
    @quotation  = args[:quotation]
    @logo       = args[:logo]
    @load_type  = args[:load_type]
    @cargo_data = {
      vol: {},
      kg: {}
    }
    @shipments.each do |s|
      @cargo_data[:kg][s.id] =  if s.aggregated_cargo
                                 s.aggregated_cargo.weight.to_f
                                else
                                 s.cargo_units.inject(0) { |sum, hash| sum + hash[:payload_in_kg].to_f }
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

  def generate
    doc_erb = ErbTemplate.new(
      layout:   @layout,
      template: @template,
      locals:   {
        shipment:  @shipment,
        shipments: @shipments,
        quotes:    @quotes,
        logo:      @logo,
        load_type: @load_type,
        tenant:    @shipment.tenant,
        cargo_data: @cargo_data
      }
    )
    response = BreezyPDFLite::RenderRequest.new(
      doc_erb.render
    ).submit

    if response.code.to_i == 201
      File.open('tmp/' + @full_name, 'wb') { |file| file.write(response.body) }
      @path = 'tmp/' + @full_name
      @pdf  = File.open(@path)
      self
    else
      raise
    end
  end

  def upload
    @doc = DocumentTools.new_upload_backend(@pdf, @shipment, @name, @shipment.user)
    @url = @doc.get_signed_url
  end

  def upload_quotes
    @doc = DocumentTools.new_upload_backend_with_quotes(@pdf, @shipment, @quotation, @name, @shipment.user)
    @url = @doc.get_signed_url
  end
end
