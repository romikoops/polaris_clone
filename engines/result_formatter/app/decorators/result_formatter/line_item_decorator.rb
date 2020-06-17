# frozen_string_literal: true

module ResultFormatter
  class LineItemDecorator < Draper::Decorator
    delegate_all
    delegate :code, :name, to: :charge_category
    delegate :mode_of_transport, to: :tender

    def total
      amount
    end

    def original_total
      original_amount
    end

    def description
      determine_render_string
    end

    def fee_context
      {
        included: included_fee?,
        excluded: excluded_fee?
      }
    end

    private

    def scope
      context[:scope]
    end

    def included_fee?
      code.include? "included"
    end

    def excluded_fee?
      code.include? "unknown"
    end

    def adjusted_key
      adjusted_code = code.sub("included_", "").sub("unknown_", "")
      adjusted_code.tr("_", " ").upcase
    end

    def adjusted_name
      if section == "cargo_section" && scope["consolidated_cargo"] && mode_of_transport == "ocean"
        "Ocean Freight"
      elsif section == "cargo_section" && scope["consolidated_cargo"]
        "Consolidated Freight Rate"
      elsif section == "cargo_section" && !scope["fine_fee_detail"]
        "#{mode_of_transport&.capitalize} Freight Rate"
      elsif %w[trucking_on_section trucking_pre_section].include?(section)
        "Trucking Rate"
      else
        name
      end
    end

    def determine_render_string
      return adjusted_name if %w[trucking_on_section trucking_pre_section].include?(section)

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
