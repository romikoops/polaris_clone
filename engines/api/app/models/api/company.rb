# frozen_string_literal: true

module Api
  class Company < Companies::Company
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

    filterrific(
      default_filter_params: { sorted_by: "name_asc" },
      available_filters: Api::Company::AVAILABLE_FILTERS
    )

    scope :sorted_by, lambda { |sort_option|
      direction = /desc$/.match?(sort_option) ? "desc" : "asc"
      case sort_option.to_s
      when /^name/
        order(sanitize_sql_for_order("name #{direction}"))
      when /^country/
        joins(:country).order(sanitize_sql_for_order("countries.name #{direction}"))
      when /^activity/
        joins("INNER JOIN journey_queries ON companies_companies.id = journey_queries.company_id").order(sanitize_sql_for_order("journey_queries.updated_at #{direction}"))
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
  end
end

# == Schema Information
#
# Table name: companies_companies
#
#  id                  :uuid             not null, primary key
#  contact_email       :string
#  contact_person_name :string
#  contact_phone       :string
#  deleted_at          :datetime
#  email               :string
#  name                :string
#  payment_terms       :text
#  phone               :string
#  registration_number :string
#  vat_number          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :integer
#  external_id         :string
#  organization_id     :uuid
#  tenants_company_id  :uuid
#
# Indexes
#
#  index_companies_companies_on_address_id          (address_id)
#  index_companies_companies_on_organization_id     (organization_id)
#  index_companies_companies_on_tenants_company_id  (tenants_company_id)
#
# Foreign Keys
#
#  fk_rails_...  (address_id => addresses.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
