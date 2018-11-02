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
        tenant:    @shipment.tenant
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
