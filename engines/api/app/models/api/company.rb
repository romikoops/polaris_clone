# frozen_string_literal: true

module Api
  class Company < Companies::Company
    delegate :street_number, :street, :city, :postal_code, :country, to: :address, allow_nil: true

    AVAILABLE_FILTERS = %i[
      sorted_by
      name_search
      country_search
      activity_search
    ].freeze

    SUPPORTED_SEARCH_OPTIONS = %w[
      name
      country
      activity
    ].freeze

    SUPPORTED_SORT_OPTIONS = %w[
      name
      country
      activity
    ].freeze

    DEFAULT_FILTER_PARAMS = { sorted_by: "name_asc" }.freeze

    filterrific(
      default_filter_params: DEFAULT_FILTER_PARAMS,
      available_filters: Api::Company::AVAILABLE_FILTERS
    )

    scope :sorted_by, lambda { |sort_option|
      direction = /desc$/.match?(sort_option) ? "desc" : "asc"
      case sort_option.to_s
      when /^name/
        order(sanitize_sql_for_order("companies_companies.name #{direction}"))
      when /^country/
        joins(:country).order(sanitize_sql_for_order("countries.name #{direction}"))
      when /^activity/
        sql_query = "SELECT companies_companies.*, MAX(journey_queries.updated_at) as last_activity
                     from companies_companies
                     INNER JOIN journey_queries ON journey_queries.company_id=companies_companies.id
                     GROUP BY companies_companies.id"
        from("(#{sql_query}) as companies_companies").order(sanitize_sql_for_order("last_activity #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_by.inspect}")
      end
    }

    scope :name_search, lambda { |input|
      where("companies_companies.name ILIKE ?", "%#{input}%")
    }

    scope :country_search, lambda { |input|
      joins(:country).where("countries.name ILIKE ?", "%#{input}%")
    }

    scope :activity_search, lambda { |range|
      joins("INNER JOIN journey_queries ON companies_companies.id = journey_queries.company_id")
        .where("journey_queries.updated_at": range).distinct
    }

    def last_activity_at
      Journey::Query.where(company_id: id).maximum(:updated_at)
    end
  end
end

# == Schema Information
#
# Table name: companies_companies
#
#  id                   :uuid             not null, primary key
#  contact_email        :string
#  contact_person_name  :string
#  contact_phone        :string
#  deleted_at           :datetime
#  email                :string
#  external_id_20220118 :string
#  name                 :citext           not null
#  payment_terms        :text
#  phone                :string
#  registration_number  :string
#  vat_number           :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  address_id           :integer
#  organization_id      :uuid
#  tenants_company_id   :uuid
#
# Indexes
#
#  index_companies_companies_on_address_id                (address_id)
#  index_companies_companies_on_organization_id           (organization_id)
#  index_companies_companies_on_organization_id_and_name  (organization_id, lower((name)::text)) UNIQUE WHERE (deleted_at IS NULL)
#  index_companies_companies_on_tenants_company_id        (tenants_company_id)
#
# Foreign Keys
#
#  fk_rails_...  (address_id => addresses.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
