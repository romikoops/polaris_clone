# frozen_string_literal: true

module Pdf
  class CargoDecorator < ApplicationDecorator
    delegate_all
    delegate :humanize, to: :total_weight, prefix: true
    delegate :humanize, to: :unit_weight, prefix: true
    delegate :mode_of_transport, :shipment, to: :tender

    def chargeable_weight
      @chargeable_weight ||=
        [
          (object.volume.value *
            Legacy::CargoItem::EFFECTIVE_TONNAGE_PER_CUBIC_METER[mode_of_transport.to_sym] *
            1000),
          object.weight.value
        ].max
    end

    def gross_weight_per_item
      return if scope["cargo_overview_only"]

      locals = {weight: unit_weight_humanize}
      h.render template: "pdf/partials/quotation/cargo/gross_weight_per_item", locals: locals
    end

    def unit_weight
      object.weight.convert_to(weight_unit)
    end

    def total_weight
      object.total_weight.convert_to(weight_unit)
    end

    def total_volume_format
      total_volume.value.round(3)
    end

    def weight_unit
      scope.dig("values", "weight", "unit")
    end

    def determine_chargeable_weight_row
      case scope["chargeable_weight_view"]
      when "weight"
        ["weight", total_chargeable_weight]
      when "volume"
        ["volume", total_chargeable_volume]
      when "both"
        ["both", total_chargeable_volume]
      when "dynamic"
        if show_volume
          ["volume", total_chargeable_volume]
        else
          ["weight", total_chargeable_weight]
        end
      end
    end

    def render_chargeable_weight_row
      row, value = determine_chargeable_weight_row
      h.render template: "pdf/partials/quotation/cargo/chargeable_weight_rows/#{row}", locals: {value: value}
    end

    def total_chargeable_weight
      chargeable_weight * quantity
    end

    def total_chargeable_volume
      (chargeable_weight / 1000.0 * quantity).round(3)
    end

    def show_volume
      volume.value > payload_in_tons.value
    end

    def payload_in_tons
      weight.convert_to(:t)
    end

    def tender
      @tender ||= context.dig(:tender)
    end

    def cargo_item_type_description
      # what about this || - when object is  a cargo::cargo
      return "Units" if object.is_a?(::Cargo::Cargo)
      return "Unit" if legacy.blank?

      legacy.cargo_item_type.description
    end

    def legacy
      @legacy ||= object.legacy
    end

    def dimensions_format
      h.content_tag :p do
        [length, width, height].map(&:format).join(" x ")
      end
    end

    def size_class
      @size_class ||= begin
        legacy_cargo_map.keys.find do |key|
          legacy_cargo_map[key]["class"] == object.cargo_class &&
            legacy_cargo_map[key]["type"] == object.cargo_type
        end
      end
    end

    def legacy_cargo_map
      Cargo::Creator::LEGACY_CARGO_MAP
    end
  end
end
