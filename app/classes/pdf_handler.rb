# frozen_string_literal: true

class PdfHandler
  attr_reader :name, :full_name, :pdf, :url, :path

  def initialize(args={})
    @layout   = args[:layout]   || args["layout"]
    @template = args[:template] || args["template"]
    @margin   = args[:margin]   || args["margin"]
    @shipment = args[:shipment] || args["shipment"]
    @name     = args[:name]     || args["name"]
    @quotes   = args[:quotes]   || args["quotes"]

    @full_name = "#{@name}_#{@shipment.imc_reference}.pdf"
  end
  
  def generate
    doc_erb = ErbTemplate.new(
      layout:   @layout,
      template: @template,
      locals:   { shipment: @shipment, quotes: @quotes }
    )

    @raw_pdf_string = WickedPdf.new.pdf_from_string(
      doc_erb.render,
      margin: @margin
    )
    
    File.open("tmp/" + @full_name, "wb") { |file| file.write(@raw_pdf_string) }
    @path = "tmp/" + @full_name
    @pdf  = File.open(@path)
    self
  end

  def upload
    @doc = Document.new_upload_backend(@pdf, @shipment, @name, @shipment.user)
    @url = @doc.get_signed_url
    self
  end

  # def upload_quotes
  #   @doc = Document.new_upload_backend_with_quotes(@pdf, @shipment, @quotes, @name, @shipment.user)
  #   @url = @doc.get_signed_url
  #   self
  # end
end
