# frozen_string_literal: true

module Notifications
  class CargoUnitDecorator < Draper::Decorator
    delegate_all

    def dimensions
      [dimensions_without_weight, weight_suffix].compact.join(" ")
    end

    def cargo_type
      case cargo_class
      when "lcl"
        I18n.t("notifications.request_mailer.request_created.#{colli_type}")
      when "aggregated_lcl"
        I18n.t("notifications.request_mailer.request_created.aggregated_lcl")
      else
        cargo_class.humanize.upcase
      end
    end

    def imo_classes
      @imo_classes ||= commodity_infos.where.not(imo_class: nil)
    end

    def commodity_codes
      @commodity_codes ||= commodity_infos.where.not(hs_code: nil)
    end

    private

    def lcl_dimensions
      # rubocop:disable Style/StringConcatenation
      [
        length,
        width,
        height
      ].map { |measure| measure.format(with_conversion_string: false) }.join(" x ") + " " + I18n.t("notifications.request_mailer.request_created.dimensions_key")
      # rubocop:enable Style/StringConcatenation
    end

    def aggregated_lcl_dimensions
      volume.format(with_conversion_string: false)
    end

    def weight_suffix
      "@ #{weight.format(with_conversion_string: false)}"
    end

    def dimensions_without_weight
      case cargo_class
      when "lcl"
        lcl_dimensions
      when "aggregated_lcl"
        aggregated_lcl_dimensions
      end
    end
  end
end
