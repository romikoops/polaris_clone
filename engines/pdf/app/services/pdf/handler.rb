# frozen_string_literal: true

require 'pdfkit'
require 'open-uri'
module Pdf
  class Handler < Pdf::Base
    FEE_DETAIL_LEVEL = 3

    attr_reader :name, :full_name, :pdf, :url, :path

    def initialize(args = {})
      super(organization: args[:organization], user: args[:shipment].user)

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
      @cargo_units           = args[:cargo_units]
      @note_remarks          = args[:note_remarks]
      @selected_offer = args[:selected_offer]
      @hide_cargo_sub_totals = false
      @content               = {}
      @has_legacy_charges = {}
      @notes = {}

      @pricing_data = {}
      @fee_keys_and_names = {}
      @cargo_data = {
        vol: {},
        kg: {},
        chargeable_weight: {},
        item_strings: {}
      }

      @shipments << @shipment if @shipments.empty?
      @shipments.map(&:charge_breakdowns).flatten.each do |charge_breakdown|
      end

      Quotations::Tender.where(id: @quotes.pluck('tender_id')).each do |tender|
        prep_notes(tender: tender)
      end
      @content = Legacy::Content.get_component('QuotePdf', @shipment.organization_id) if @name == 'quotation'
      @full_name = "#{@name}_#{@shipment.imc_reference}.pdf"
    end

    def prep_notes(tender:)
      notes = Notes::Service.new(tender: tender, remarks: false).fetch.entries

      @notes[tender.id] = notes
    end


    def generate
      pdf_html = ActionController::Base.new.render_to_string(
        layout: @layout,
        template: @template,
        locals: locals_for_generation
      )

      pdf = PDFKit.new(pdf_html)

      pdf.to_pdf
    end

    def locals_for_generation
      {
        shipment: @shipment,
        shipments: @shipments,
        quotation: @quotation,
        quotes: @quotes,
        logo: @logo,
        load_type: @load_type,
        remarks: @remarks,
        organization: @organization,
        theme: @theme,
        cargo_data: @cargo_data,
        notes: @notes,
        hide_cargo_sub_totals: @hide_cargo_sub_totals,
        content: @content,
        has_legacy_charges: @has_legacy_charges,
        pricing_data: @pricing_data,
        scope: @scope,
        cargo_units: @cargo_units,
        note_remarks: @note_remarks,
        shipper_profile: profile_for_user(user_id: @shipment.user_id),
        fees: @fees,
        exchange_rates: exchange_rates,
        selected_offer: @selected_offer
      }
    end

    def ensure_chargeable_weight_and_quantity(cargo:)
      cargo.set_chargeable_weight! unless cargo[:chargeable_weight]
      cargo[:chargeable_weight] = cargo.calc_chargeable_weight('ocean') unless cargo[:chargeable_weight]
      cargo[:quantity] || 1
    end

    def profile_for_user(user_id:)
      Profiles::ProfileService.fetch(user_id: user_id)
    end

    def currency
      @currency ||= Users::Settings.find_by(user: @shipment.user)&.currency || @organization.scope.currency
    end

    def exchange_rates
      @shipments.flat_map(&:charge_breakdowns).reduce({}) do |result, charge_breakdown|
        rate = ResultFormatter::ExchangeRateService.new(tender: charge_breakdown.tender).perform
        result.merge(rate)
      end
    end
  end
end
