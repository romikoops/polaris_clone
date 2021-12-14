# frozen_string_literal: true

module Api
  class ShipmentRequest < ::Journey::ShipmentRequest
    self.inheritance_column = nil

    filterrific(
      default_filter_params: { sorted_by: "created_at_desc" },
      available_filters: %i[sorted_by]
    )

    scope :sorted_by, lambda { |sort_option|
      direction = /desc$/.match?(sort_option) ? "desc" : "asc"
      case sort_option.to_s
      when /^created_at/
        order(sanitize_sql_for_order("created_at #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
      end
    }
  end
end
