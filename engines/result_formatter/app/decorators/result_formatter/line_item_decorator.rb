# frozen_string_literal: true

module ResultFormatter
  class LineItemDecorator < ApplicationDecorator
    ADORNMENTS_BY_RATE_BASIS = {
      "kg" => %w[PER_KG PER_KG_FLAT PER_X_KG_FLAT PER_X_KG PER_KG_RANGE PER_KG_RANGE_FLAT PER_UNIT_KG],
      "wm" => %w[PER_WM PER_WM_RANGE PER_WM_RANGE_FLAT],
      "cbm" => %w[PER_CBM PER_CBM_RANGE PER_CBM_RANGE_FLAT],
      "unit" => %w[PER_UNIT PER_UNIT_RANGE PER_UNIT_RANGE_FLAT PER_ITEM],
      "container" => %w[PER_CONTAINER],
      "km" => %w[PER_KM PER_KM_RANGE PER_KM_RANGE_FLAT PER_X_KM],
      "ton" => %w[PER_TON],
      "shipment" => %w[PER_SHIPMENT PER_BILL],
      "%" => %w[PERCENTAGE]
    }.freeze

    delegate_all
    delegate :mode_of_transport, to: :route_section

    def original_total
      total
    end

    def description
      determine_render_string
    end

    def fee_context
      {
        included: included,
        excluded: optional
      }
    end

    def rate_basis
      @rate_basis ||= breakdown_rate_data["rate_basis"]
    end

    def rate
      @rate ||= if charged_rate.present?
        [
          percentage_fee? ? format("%g", charged_rate) : Money.new(charged_rate, total_currency).format(symbol: "#{total_currency} ", rounded_infinite_precision: true),
          rate_factor_adornment
        ].join(percentage_fee? ? "" : " / ")
      end
    end

    def rate_factor
      @rate_factor ||= "#{format('%g', calculated_rate_factor)} #{pluralised_rate_factor_adornment}" if show_rate_and_factor?
    end

    private

    def pluralised_rate_factor_adornment
      return rate_factor_adornment.pluralize if calculated_rate_factor > 1 && %w[unit container].include?(rate_factor_adornment)

      rate_factor_adornment
    end

    def show_rate_and_factor?
      !percentage_fee? && !included && !optional && rate_basis != "PER_SHIPMENT" && charged_rate.present?
    end

    def charged_rate
      @charged_rate ||= begin
        found_rate = breakdown_rate_data.values_at("rate", "percentage", "value").find(&:present?)
        found_rate.to_d * 100.0 if found_rate.present?
      end
    end

    def calculated_rate_factor
      @calculated_rate_factor ||= case rate_factor_adornment
                                  when "unit", "container"
                                    units
                                  else
                                    total_cents / [charged_rate, 1].compact.max
      end
    end

    def scope
      context[:scope]
    end

    def adjusted_key
      adjusted_code = fee_code.sub("included_", "").sub("unknown_", "")
      adjusted_code.tr("_", " ").upcase
    end

    def adjusted_name
      if freight_fee? && scope["consolidated_cargo"] && mode_of_transport == "ocean"
        "Ocean Freight"
      elsif freight_fee? && scope["consolidated_cargo"]
        "Consolidated Freight Rate"
      elsif freight_fee? && !scope["fine_fee_detail"]
        "#{mode_of_transport&.capitalize} Freight Rate"
      else
        object.description
      end
    end

    def transfer_fee?
      mode_of_transport == "relay"
    end

    def freight_fee?
      mode_of_transport != :carriage? && !transfer_fee?
    end

    def determine_render_string
      return adjusted_name if route_section.mode_of_transport == :carriage?

      case scope["fee_detail"]
      when "key"
        adjusted_key.tr("_", " ").upcase
      when "key_and_name"
        "#{adjusted_key.upcase} - #{adjusted_name}"
      else
        adjusted_name
      end
    end

    def breakdown
      @breakdown ||= Pricings::Breakdown.joins(:charge_category).joins(:metadatum).where(pricings_metadata: { result_id: line_item_set.result_id }, charge_categories: { code: fee_code }).order(order: :asc).last
    end

    def rate_factor_adornment
      @rate_factor_adornment ||= ADORNMENTS_BY_RATE_BASIS.keys.find { |modifier| ADORNMENTS_BY_RATE_BASIS[modifier].include?(rate_basis) }
    end

    def breakdown_rate_data
      return {} if breakdown.blank? || breakdown.data.empty?

      @breakdown_rate_data ||= if breakdown.data.key?("rate_basis")
        breakdown.data
      elsif breakdown.rate_origin["type"] == "Trucking::Trucking"
        breakdown.data.entries.dig(0, 1, 0, "rate") || {}
      else
        {}
      end
    end

    def percentage_fee?
      @percentage_fee ||= rate_basis == "PERCENTAGE"
    end
  end
end
