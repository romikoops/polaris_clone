# frozen_string_literal: true

module Api
  class Query < ::Journey::Query
    include PgSearch::Model
    belongs_to :client, class_name: "Api::Client"
    has_one :client_profile, through: :client, source: :profile

    AVAILABLE_FILTERS = %i[
      sorted_by
      reference_search
      client_email_search
      client_name_search
      company_name_search
      origin_search
      destination_search
      imo_class_search
      hs_code_search
      load_type_search
      billable_search
      mot_search
    ].freeze

    SUPPORTED_SEARCH_OPTIONS = %w[
      reference
      client_email
      client_name
      company_name
      origin
      destination
      load_type
      billable
      imo_class
      hs_code
      mot
    ].freeze

    SUPPORTED_SORT_OPTIONS = %w[
      created_at
      origin
      destination
      load_type
      last_name
      selected_date
      cargo_ready_date
    ].freeze

    DEFAULT_FILTER_PARAMS = { sorted_by: "created_at_desc" }.freeze

    filterrific(
      default_filter_params: DEFAULT_FILTER_PARAMS,
      available_filters: AVAILABLE_FILTERS
    )

    pg_search_scope :search,
      against: %i[origin destination],
      associated_against: {
        company: :name,
        client: :email,
        client_profile: %i[first_name last_name phone]
      },
      using: {
        tsearch: { prefix: true }
      }

    scope :sorted_by, lambda { |sort_option|
      direction = /desc$/.match?(sort_option) ? "desc" : "asc"
      case sort_option.to_s

      when /^load_type/
        order(sanitize_sql_for_order("load_type #{direction}"))
      when /^last_name/
        joins(client: :profile).order(sanitize_sql_for_order("last_name #{direction}"))
      when /^origin/
        order(sanitize_sql_for_order("origin #{direction}"))
      when /^destination/
        order(sanitize_sql_for_order("destination #{direction}"))
      when /^selected_date|^cargo_ready_date/
        order(sanitize_sql_for_order("cargo_ready_date #{direction}"))
      when /^created_at/
        order(sanitize_sql_for_order("created_at #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
      end
    }

    scope :from_current_organization, lambda {
      where(organization_id: ::Organizations.current_id)
    }

    scope :reference_search, lambda { |input|
      joins(results: :line_item_sets).where("reference ILIKE ?", "%#{input}%").distinct("journey_queries.id")
    }

    scope :client_email_search, lambda { |input|
      joins(:client).where("email ILIKE ?", "%#{input}%")
    }

    scope :client_name_search, lambda { |input|
      joins(client: :profile).where("first_name ILIKE ? OR last_name ILIKE ?", "%#{input}%", "%#{input}%")
    }

    scope :company_name_search, lambda { |input|
      joins(:company).where("name ILIKE ?", "%#{input}%")
    }

    scope :origin_search, lambda { |input|
      where("origin ILIKE ?", "%#{input}%")
    }

    scope :destination_search, lambda { |input|
      where("destination ILIKE ?", "%#{input}%")
    }

    scope :load_type_search, lambda { |input|
      where(load_type: input)
    }

    scope :billable_search, lambda { |input|
      where(billable: input)
    }

    scope :imo_class_search, lambda { |input|
      joins(cargo_units: :commodity_infos).where("hs_code is NULL AND description ILIKE ?", "%#{input}%")
    }

    scope :hs_code_search, lambda { |input|
      joins(cargo_units: :commodity_infos).where("imo_class IS NULL AND description ILIKE ?", "%#{input}%")
    }

    scope :mot_search, lambda { |input|
      joins(results: :route_sections).where(journey_route_sections: { mode_of_transport: input.to_s })
    }

    def client
      super || Users::Client.new
    end
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
#  currency                :string
#  customs                 :boolean          default(FALSE)
#  delivery_date           :datetime         not null
#  destination             :string           not null
#  destination_coordinates :geometry         not null, geometry, 4326
#  insurance               :boolean          default(FALSE)
#  load_type               :enum             not null
#  origin                  :string           not null
#  origin_coordinates      :geometry         not null, geometry, 4326
#  status                  :enum
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  client_id               :uuid
#  company_id              :uuid
#  creator_id              :uuid
#  destination_geo_id      :string
#  organization_id         :uuid
#  origin_geo_id           :string
#  parent_id               :uuid
#  source_id               :uuid             not null
#
# Indexes
#
#  index_journey_queries_on_billable                     (billable)
#  index_journey_queries_on_client_id                    (client_id)
#  index_journey_queries_on_company_id                   (company_id)
#  index_journey_queries_on_creator_id_and_creator_type  (creator_id,creator_type)
#  index_journey_queries_on_organization_id              (organization_id)
#  index_journey_queries_on_parent_id                    (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id) ON DELETE => cascade
#  fk_rails_...  (organization_id => organizations_organizations.id) ON DELETE => cascade
#  fk_rails_...  (parent_id => journey_queries.id)
#
