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
