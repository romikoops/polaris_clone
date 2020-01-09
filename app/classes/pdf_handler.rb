# frozen_string_literal: true

require 'pdfkit'
require 'open-uri'
class PdfHandler # rubocop:disable Metrics/ClassLength
  include ApplicationHelper
  BreezyError = Class.new(StandardError)

  attr_reader :name, :full_name, :pdf, :url, :path

  def initialize(args = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
    @hide_cargo_sub_totals = false
    @content               = {}
    @hide_grand_total = {}
    @has_legacy_charges = {}
    @notes = {}
    tenants_tenant = Tenants::Tenant.find_by(legacy_id: @shipment.tenant_id)
    @scope = ::Tenants::ScopeService.new(
      target: ::Tenants::User.find_by(legacy_id: @shipment.user.id),
      tenant: tenants_tenant
    ).fetch
    @pricing_data = {}
    @fee_keys_and_names = {}
    @cargo_data = {
      vol: {},
      kg: {},
      chargeable_weight: {},
      item_strings: {}
    }

    @quotes.each { |quote| generate_fee_string(quote) }
    @shipments << @shipment if @shipments.empty?
    @shipments.each do |s|
      calculate_cargo_data(s)
      calculate_pricing_data(s)
      prep_notes(s)
      @hide_grand_total[s.id] = hide_grand_total?(s)
    end
    @content = Content.get_component('QuotePdf', @shipment.tenant_id) if @name == 'quotation'

    @full_name = "#{@name}_#{@shipment.imc_reference}.pdf"
  end

  def calculate_pricing_data(shipment)
    @pricing_data[shipment.id] = shipment.meta['pricing_rate_data']
  end

  def prep_notes(shipment)
    hubs = [shipment.origin_hub, shipment.destination_hub].compact
    return hubs if hubs.empty?

    nexii = hubs.map(&:nexus)
    countries = nexii.map(&:country)
    legacy_pricings = shipment.itinerary&.pricings&.for_cargo_classes(shipment.cargo_classes)
    pricings = shipment.itinerary&.rates&.for_cargo_classes(shipment.cargo_classes)
    notes_association = Note.where(
      tenant_id: shipment.tenant_id,
      transshipment: false,
      remarks: false
    )
    @notes[shipment.id] = notes_association
                          .where(target: hubs | nexii | countries | legacy_pricings)
                          .or(notes_association.where(pricings_pricing_id: pricings.ids))
  end

  def generate_fee_string(quote)
    quote
      .slice('import', 'export', 'cargo', 'trucking_pre', 'trucking_on')
      .each do |charge_section_key, charge_section|
      charge_section_keys = charge_section
                            .except('total', 'edited_total', 'name')
                            .keys
      charge_section_keys.each do |subsection_key|
        mode_of_transport = quote.fetch('mode_of_transport')
        charge_section[subsection_key]
          .except('total', 'edited_total', 'name')
          .each do |charge_key, fee_value|
          adjusted_key = extract_key(
            section_key: charge_section_key,
            key: charge_key,
            mot: mode_of_transport
          )
          adjusted_name = extract_name(
            section_key: charge_section_key,
            name: fee_value.fetch('name'),
            mot: mode_of_transport
          )
          @fee_keys_and_names[charge_key] = determine_render_string(
            key: adjusted_key,
            name: adjusted_name
          )
        end
      end
    end

    @fee_keys_and_names
  end

  def extract_key(section_key:, key:, mot:)
    if section_key == 'cargo' && @scope['fine_fee_detail'] && key.include?('unknown')
      "#{mot.capitalize} Freight"
    elsif section_key == 'cargo' && @scope['fine_fee_detail'] && key.include?('included')
      key.sub('included_', '')&.upcase.to_s
    else
      key.tr('_', ' ').upcase
    end
  end

  def extract_name(section_key:, name:, mot:)
    if section_key == 'cargo' && @scope['consolidated_cargo']
      'Consolidated Freight Rate'
    elsif section_key == 'cargo' && !@scope['fine_fee_detail']
      "#{mot&.capitalize} Freight Rate"
    elsif %w[trucking_on trucking_pre].include?(section_key)
      'Trucking Rate'
    else
      name
    end
  end

  def determine_render_string(key:, name:)
    case @scope['fee_detail']
    when 'key'
      key.tr('_', ' ').upcase
    when 'key_and_name'
      "#{key.upcase} - #{name}"
    when 'name'
      name
    end
  end

  def hide_grand_total?(shipment) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return true if @scope['hide_grand_total']
    return false if !@scope['hide_grand_total'] && !@scope['hide_converted_grand_total']

    currencies = []
    result = shipment
             .selected_offer
             .except('total', 'edited_total', 'name', 'trip_id', 'valid_until')
             .find do |charge_key, charge|
               charge_keys = charge
                             .except('total', 'edited_total', 'name')
                             .keys

               charge_currencies = if %w[export import].include?(charge_key)
                                     charge_keys.map { |k| charge[k]['currency'] }
                                   elsif charge_key == 'cargo'
                                     charge_keys
                                       .map do |k|
                                         charge[k]
                                           .except('total', 'edited_total', 'name')
                                           .keys
                                           .reject { |rk| rk.include?('unknown') }
                                           .map do |ck|
                                             if %w[cargo_item container].include?(k)
                                               charge.dig(k, 'currency')
                                             else
                                               charge.dig(k, ck, 'currency')
                                             end
                                           end
                                       end
                                   else
                                     charge_keys.map { |k| charge[k]['total']['currency'] }
                                   end
               currencies += charge_currencies.flatten.compact
               currencies.uniq.count > 1
             end

    result.present? || (currencies.uniq.first != shipment.user.currency)
  end

  def calculate_cargo_data(shipment)
    kg = if shipment.aggregated_cargo
           shipment.aggregated_cargo.weight.to_f
         else
           shipment.cargo_units.inject(0) do |sum, hash|
             sum + hash[:quantity].to_f * hash[:payload_in_kg].to_f
           end
         end
    quantity_strings = {}
    shipment.cargo_units.each do |unit|
      cargo_class = unit.is_a?(CargoItem) ? unit.cargo_item_type.description : unit.size_class.humanize.upcase
      quantity_strings[unit.id.to_s] = "#{unit.quantity} x #{cargo_class}"
    end
    @cargo_data[:item_strings][shipment.id] = quantity_strings

    unless shipment.fcl?
      chargeable_weight = {}
      shipment.aggregated_cargo&.set_chargeable_weight!
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
      chargeable_value = if shipment.aggregated_cargo
                           agg = shipment.aggregated_cargo
                           (agg.chargeable_weight || agg.calc_chargeable_weight('ocean'))&.to_f
                         else
                           shipment.cargo_units.inject(0) do |sum, hash|
                             sum + hash[:quantity].to_f * hash[:chargeable_weight].to_f
                           end
                         end

      lcl_units = ([shipment.aggregated_cargo] + shipment.cargo_items).compact
      case @scope['chargeable_weight_view']
      when 'weight'
        chargeable_weight_cargo = chargeable_value
        cargo_string = " (Chargeable Weight: #{format('%.2f', chargeable_weight_cargo)} kg)"
        lcl_units.each do |hash|
          single_string = "#{format('%.2f', hash[:chargeable_weight])} kg"
          total_string = "#{format('%.2f', hash[:chargeable_weight])} kg"
          chargeable_weight[hash[:id].to_s] = {
            single_value: single_string,
            single_title: 'Chargeable&nbsp;Weight',
            total_value: total_string,
            total_title: 'Total&nbsp;Chargeable&nbsp;Weight'
          }
        end
      when 'volume'
        chargeable_weight_cargo = chargeable_value / 1000
        cargo_string = " (Chargeable Volume: #{format('%.3f', chargeable_weight_cargo)} m<sup>3</sup>)"
        lcl_units.each do |hash|
          quantity = ensure_chargeable_weight_and_quantity(cargo: hash)
          single_string = "#{format('%.3f', (hash[:chargeable_weight] / 1000))} m<sup>3</sup>"
          total_string = "#{format('%.3f', (hash[:chargeable_weight] / 1000 * quantity))} m<sup>3</sup>"
          chargeable_weight[hash[:id].to_s] = {
            single_value: single_string,
            single_title: 'Chargeable&nbsp;Volume',
            total_value: total_string,
            total_title: 'Total&nbsp;Chargeable&nbsp;Volume'
          }
        end
      when 'dynamic'
        show_volume = vol > (kg / 1000)
        chargeable_weight_cargo = show_volume ? chargeable_value / 1000 : chargeable_value
        cargo_string = if show_volume
                         " (Chargeable&nbsp;Volume: #{chargeable_weight_cargo} m<sup>3</sup>)"
                       else
                         " (Chargeable&nbsp;Weight: #{chargeable_weight_cargo} kg)"
                       end
        lcl_units.each do |hash|
          quantity = ensure_chargeable_weight_and_quantity(cargo: hash)
          single_string = if show_volume
                            "#{format('%.3f', (hash[:chargeable_weight] / 1000))} m<sup>3</sup>"
                          else
                            "#{format('%.2f', hash[:chargeable_weight])} kg"
                          end
          total_string = if show_volume
                           "#{format('%.3f', (hash[:chargeable_weight] * quantity / 1000))} m<sup>3</sup>"
                         else
                           "#{format('%.2f', (hash[:chargeable_weight] * quantity))} kg"
                         end

          chargeable_weight[hash[:id].to_s] = {
            single_value: single_string,
            single_title: show_volume ? 'Chargeable&nbsp;Volume' : 'Chargeable&nbsp;Weight',
            total_value: total_string,
            total_title: show_volume ? 'Total&nbsp;Chargeable&nbsp;Volume' : 'Total&nbsp;Chargeable&nbsp;Weight'
          }
        end
      when 'both'
        chargeable_weight_cargo = chargeable_value / 1000
        cargo_string = " (Chargeable: #{format('%.3f', chargeable_weight_cargo)} t | m<sup>3</sup>)"
        lcl_units.each do |hash|
          quantity = ensure_chargeable_weight_and_quantity(cargo: hash)
          single_string = "#{format('%.3f', (hash[:chargeable_weight] / 1000))} t | m<sup>3</sup>"
          total_string = "#{format('%.3f', (hash[:chargeable_weight] * quantity / 1000))} t | m<sup>3</sup>"
          chargeable_weight[hash[:id].to_s] = {
            single_value: single_string,
            single_title: 'Chargeable',
            total_value: total_string,
            total_title: 'Total&nbsp;Chargeable'
          }
        end
      else
        chargeable_weight_cargo = chargeable_value / 1000
        cargo_string = " (Chargeable: #{format('%.3f', chargeable_weight_cargo)} t | m<sup>3</sup>)"
        lcl_units.each do |hash|
          quantity = ensure_chargeable_weight_and_quantity(cargo: hash)
          single_string = "#{format('%.3f', (hash[:chargeable_weight] / 1000))} t | m<sup>3</sup>"
          total_string = "#{format('%.3f', (hash[:chargeable_weight] * quantity / 1000))} t | m<sup>3</sup>"
          chargeable_weight[hash[:id].to_s] = {
            single_value: single_string,
            single_title: 'Chargeable',
            total_value: total_string,
            total_title: 'Total&nbsp;Chargeable'
          }
        end
      end
      chargeable_weight[:cargo] = "<small class='chargeable_weight'>#{cargo_string}</small>"
      trucking_pre_string =
        " (Chargeable Weight: #{@shipment.trucking.dig('pre_carriage', 'chargeable_weight')} kg)"
      trucking_on_string =
        " (Chargeable Weight: #{@shipment.trucking.dig('on_carriage', 'chargeable_weight')} kg)"
      chargeable_weight[:trucking_pre] = "<small class='chargeable_weight'>#{trucking_pre_string}</small>"
      chargeable_weight[:trucking_on] = "<small class='chargeable_weight'>#{trucking_on_string}</small>"
      @cargo_data[:chargeable_weight][shipment.id] = chargeable_weight
      @cargo_data[:vol][shipment.id] = vol
    end
    @cargo_data[:kg][shipment.id] = kg
  end

  def generate
    pdf_html = ActionController::Base.new.render_to_string(
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
        notes: @notes,
        hide_cargo_sub_totals: @hide_cargo_sub_totals,
        content: @content,
        hide_grand_total: @hide_grand_total,
        has_legacy_charges: @has_legacy_charges,
        pricing_data: @pricing_data,
        scope: @scope,
        cargo_units: @cargo_units,
        hub_names: @hub_names,
        note_remarks: @note_remarks,
        fee_keys_and_names: @fee_keys_and_names
      }
    )

    pdf = PDFKit.new(pdf_html)

    pdf.to_pdf
  end

  def ensure_chargeable_weight_and_quantity(cargo:)
    cargo.set_chargeable_weight! unless cargo[:chargeable_weight]
    cargo[:chargeable_weight] = cargo.calc_chargeable_weight('ocean') unless cargo[:chargeable_weight]
    cargo[:quantity] || 1
  end
end
