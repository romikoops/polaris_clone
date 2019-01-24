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
    @hide_grand_total = {}
    @scope = @shipment.tenant.scope

    @cargo_data = {
      vol: {},
      kg: {},
      chargeable_weight: {}
    }

    @shipments << @shipment if @shipments.empty?
    @shipments.each do |s|
      calculate_cargo_data(s)
      @hide_grand_total[s.id] = hide_grand_total?(s)
    end
    @content = Content.get_component('QuotePdf', @shipment.tenant_id) if @name == 'quotation'

    @full_name = "#{@name}_#{@shipment.imc_reference}.pdf"
  end

  def hide_grand_total?(shipment)
    return true if @scope['hide_grand_total']
    return false if !@scope['hide_grand_total'] && !@scope['hide_converted_grand_total']

    currencies = []
    result = shipment
             .selected_offer
             .except('total', 'edited_total', 'name')
             .find do |charge_key, charge|
               charge_keys = charge
                             .except('total', 'edited_total', 'name')
                             .keys
               charge_currencies = if %w(export import).include?(charge_key)
                                     charge_keys.map { |k| charge[k]['currency'] }
                                   elsif charge_key == 'cargo'
                                     charge_keys
                                       .map do |k|
                                         charge[k]
                                           .except('total', 'edited_total', 'name')
                                           .keys
                                           .reject { |rk| rk.include?('unknown') }
                                           .map { |ck| charge.dig(k, ck, 'currency') }
                                       end
                                   else
                                     charge_keys.map { |k| charge[k]['total']['currency'] }
                                   end
               currencies += charge_currencies.flatten
               currencies.compact.uniq.count > 1
             end
    result.present?
  end

  def calculate_cargo_data(shipment)
    kg = if shipment.aggregated_cargo
           shipment.aggregated_cargo.weight.to_f
         else
           shipment.cargo_units.inject(0) do |sum, hash|
             sum + hash[:quantity].to_f * hash[:payload_in_kg].to_f
           end
         end
    unless shipment.fcl?
      chargeable_weight = {}
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
                           shipment.aggregated_cargo.weight.to_f
                         else
                           shipment.cargo_units.inject(0) do |sum, hash|
                             sum + hash[:quantity].to_f * hash[:chargeable_weight].to_f
                           end
                         end

      case @scope['chargeable_weight_view']
      when 'weight'
        chargeable_weight_cargo = chargeable_value
        cargo_string = " (Chargeable Weight: #{format('%.2f', chargeable_weight_cargo)} kg)"
        shipment.cargo_units.each do |hash|
          string = "#{format('%.2f', hash[:chargeable_weight])} kg"
          chargeable_weight[hash[:id].to_s] = {
            value: string,
            title: 'Chargeable Weight'
          }
        end
      when 'volume'
        chargeable_weight_cargo = chargeable_value / 1000
        cargo_string = " (Chargeable Volume: #{format('%.3f', chargeable_weight_cargo)} m<sup>3</sup>)"
        shipment.cargo_units.each do |hash|
          string = "#{format('%.3f', (hash[:chargeable_weight] / 1000))} m<sup>3</sup>"
          chargeable_weight[hash[:id].to_s] = {
            value: string,
            title: 'Chargeable&nbsp;Volume'
          }
        end
      when 'dynamic'
        show_volume = vol > kg

        chargeable_weight_cargo = show_volume ? chargeable_value / 1000 : chargeable_value
        cargo_string = if show_volume
                         " (Chargeable&nbsp;Volume: #{chargeable_weight_cargo} m<sup>3</sup>)"
                       else
                         " (Chargeable&nbsp;Weight: #{chargeable_weight_cargo} kg)"
                       end
        shipment.cargo_units.each do |hash|
          string = if show_volume
                     "#{format('%.3f', (hash[:chargeable_weight] / 1000))} m<sup>3</sup>"
                   else
                     "#{format('%.2f', hash[:chargeable_weight])} kg"
                   end
          chargeable_weight[hash[:id].to_s] = {
            value: string,
            title: show_volume ? 'Chargeable&nbsp;Volume' : 'Chargeable&nbsp;Weight'
          }
        end
      when 'both'
        chargeable_weight_cargo = chargeable_value / 1000
        cargo_string = " (Chargeable: #{format('%.3f', chargeable_weight_cargo)} t | m<sup>3</sup>)"
        shipment.cargo_units.each do |hash|
          string = "#{format('%.3f', (hash[:chargeable_weight] / 1000))} t | m<sup>3</sup>"
          chargeable_weight[hash[:id].to_s] = {
            value: string,
            title: 'Chargeable'
          }
        end
      else
        chargeable_weight_cargo = chargeable_value / 1000
        cargo_string = " (Chargeable: #{format('%.3f', chargeable_weight_cargo)} t | m<sup>3</sup>)"
        shipment.cargo_units.each do |hash|
          string = "#{format('%.3f', (hash[:chargeable_weight] / 1000))} t | m<sup>3</sup>"
          chargeable_weight[hash[:id].to_s] = {
            value: string,
            title: 'Chargeable'
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
        content: @content,
        hide_grand_total: @hide_grand_total
      }
    )
    response = BreezyPDFLite::RenderRequest.new(
      doc_erb.render
    ).submit

    raise BreezyError, response.body if response.code.to_i != 201

    response.body
  end
end
