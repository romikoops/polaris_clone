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
      when /^origin/
        sort_by_location(location_name: "from").order(sanitize_sql_for_order("journey_route_points.name #{direction}"))
      when /^destination/
        sort_by_location(location_name: "to").order(sanitize_sql_for_order("journey_route_points.name #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
      end
    }

    scope :sort_by_location, lambda { |location_name:|
      joins(result: :route_sections)
        .joins("INNER JOIN journey_route_points ON journey_route_sections.#{location_name}_id = journey_route_points.id")
        .where.not(journey_route_sections: { mode_of_transport: %w[carriage relay] })
    }
  end
end

# == Schema Information
#
# Table name: journey_shipment_requests
#
#  id                        :uuid             not null, primary key
#  commercial_value_cents    :integer
#  commercial_value_currency :string
#  notes                     :text
#  preferred_voyage          :string
#  status                    :enum
#  with_customs_handling     :boolean          default(FALSE)
#  with_insurance            :boolean          default(FALSE)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  client_id                 :uuid
#  company_id                :uuid
#  result_id                 :uuid
#
# Indexes
#
#  index_journey_shipment_requests_on_client_id   (client_id)
#  index_journey_shipment_requests_on_company_id  (company_id)
#  index_journey_shipment_requests_on_result_id   (result_id)
#  index_journey_shipment_requests_on_status      (status)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id) ON DELETE => cascade
#  fk_rails_...  (result_id => journey_results.id) ON DELETE => cascade
#
