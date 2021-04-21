# frozen_string_literal: true

module ResultFormatter
  class CargoDecorator < ApplicationDecorator
    delegate_all
    delegate :humanize, to: :total_weight, prefix: true
    delegate :humanize, to: :unit_weight, prefix: true
    delegate :mode_of_transport, :shipment, to: :result

    def chargeable_weight
      @chargeable_weight ||= Measured::Weight.new(object.volume.value * wm_ratio, "t").convert_to("kg")
    end

    def gross_weight_per_item
      return if scope["cargo_overview_only"]

      locals = { weight: unit_weight_humanize }
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
        weight: total_chargeable_weight.value.to_f,
        volume: total_chargeable_volume,
        view_type: scope["chargeable_weight_view"]
      ).perform
    end

    def render_chargeable_weight_row
      row, value = determine_chargeable_weight_row

      h.render template: "pdf/partials/quotation/cargo/chargeable_weight_rows/#{row}", locals: { value: value }
    end

    def total_chargeable_weight
      chargeable_weight.scale(quantity)
    end

    def total_chargeable_volume
      chargeable_weight.convert_to("t").scale(quantity).value.to_f.round(3)
    end

    def payload_in_tons
      weight.convert_to(:t)
    end

    def result
      @result ||= context[:result]
    end

    def cargo_item_type_description
      colli_type.to_s.humanize
    end

    def dimensions_format
      h.tag.p do
        [length, width, height].compact.map(&:format).join(" x ")
      end
    end

    def size_class
      @size_class ||= cargo_class
    end

    def wm_ratio
      context[:wm_ratio] || 0
    end
  end
end
