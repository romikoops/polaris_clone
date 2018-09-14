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

    @full_name = "#{@name}_#{@shipment.imc_reference}.pdf"
  end

  def generate
    doc_erb = ErbTemplate.new(
      layout:   @layout,
      template: @template,
      show_as_html: true,
      locals:   {
        shipment: @shipment,
        shipments: @shipments,
        quotes: @quotes,
        logo: @logo,
        tenant: @shipment.tenant
      }
      )
    @raw_pdf_string = WickedPdf.new.pdf_from_string(
      doc_erb.render,
      margin: @margin
    )

    File.open('tmp/' + @full_name, 'wb') { |file| file.write(@raw_pdf_string) }
    @path = 'tmp/' + @full_name
    @pdf  = File.open(@path)
    self
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
