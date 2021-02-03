# frozen_string_literal: true

module Api
  class Query < ::Journey::Query
    filterrific(
      default_filter_params: {sorted_by: "created_at_desc"},
      available_filters: [
        :sorted_by
      ]
    )

    scope :sorted_by, lambda { |sort_option|
      direction = /desc$/.match?(sort_option) ? "desc" : "asc"
      case sort_option.to_s

      when /^load_type_/
        order(sanitize_sql_for_order("load_type #{direction}"))
      when /^last_name_/
        joins(client: :profile).order(sanitize_sql_for_order("last_name #{direction}"))
      when /^origin_/
        order(sanitize_sql_for_order("origin #{direction}"))
      when /^destination_/
        order(sanitize_sql_for_order("destination #{direction}"))
      when /^selected_date_/
        order(sanitize_sql_for_order("cargo_ready_date #{direction}"))
      when /^created_at_/
        order(sanitize_sql_for_order("created_at #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
      end
    }
  end
end

# == Schema Information
#
# Table name: journey_queries
#
#  id                      :uuid             not null, primary key
#  billable                :boolean          default(FALSE)
#  cargo_ready_date        :datetime         not null
#  creator_type            :string
#  customs                 :boolean          default(FALSE)
#  delivery_date           :datetime         not null
#  destination             :string           not null
#  destination_coordinates :geometry         not null, geometry, 4326
#  insurance               :boolean          default(FALSE)
#  load_type               :enum
#  origin                  :string           not null
#  origin_coordinates      :geometry         not null, geometry, 4326
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  client_id               :uuid
#  company_id              :uuid
#  creator_id              :uuid
#  organization_id         :uuid
#  source_id               :uuid             not null
#
# Indexes
#
#  index_journey_queries_on_billable                     (billable)
#  index_journey_queries_on_client_id                    (client_id)
#  index_journey_queries_on_company_id                   (company_id)
#  index_journey_queries_on_creator_id_and_creator_type  (creator_id,creator_type)
#  index_journey_queries_on_organization_id              (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id) ON DELETE => cascade
#  fk_rails_...  (organization_id => organizations_organizations.id) ON DELETE => cascade
#
