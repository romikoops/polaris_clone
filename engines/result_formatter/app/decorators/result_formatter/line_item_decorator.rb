# frozen_string_literal: true

module ResultFormatter
  class LineItemDecorator < ApplicationDecorator
    delegate_all

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

    private

    def code
      fee_code
    end

    def mode_of_transport
      context.dig(:mode_of_transport)
    end

    def scope
      context[:scope]
    end

    def adjusted_key
      adjusted_code = code.sub("included_", "").sub("unknown_", "")
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
      route_section.from == route_section.to
    end

    def freight_fee?
      route_section.mode_of_transport != :carriage? && !transfer_fee?
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
  end
end
