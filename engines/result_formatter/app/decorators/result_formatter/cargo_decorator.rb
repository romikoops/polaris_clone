# frozen_string_literal: true

module ResultFormatter
  class CargoDecorator < ApplicationDecorator
    delegate_all
    delegate :humanize, to: :total_weight, prefix: true
    delegate :humanize, to: :unit_weight, prefix: true
    delegate :mode_of_transport, :shipment, to: :result

    def chargeable_weight
      @chargeable_weight ||=
        [
          (object.volume.value * wm_ratio),
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
      Pdf::ChargeableWeightRow.new(
        weight: total_chargeable_weight,
        volume: total_chargeable_volume,
        view_type: scope["chargeable_weight_view"]
      ).perform
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

    def payload_in_tons
      weight.convert_to(:t)
    end

    def result
      @result ||= context.dig(:result)
    end

    def cargo_item_type_description
      colli_type.to_s.humanize
    end

    def dimensions_format
      h.content_tag :p do
        [length, width, height].map(&:format).join(" x ")
      end
    end

    def size_class
      @size_class ||= cargo_class
    end

    def wm_ratio
      context.dig(:wm_ratio) || 0
    end
  end
end
