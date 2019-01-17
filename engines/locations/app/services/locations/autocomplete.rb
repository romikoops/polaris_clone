# frozen_string_literal: true

module Locations
  class Autocomplete
    def self.search(term:, countries:, lang: 'en')
      query = Locations::Name

      query = query.where(country_code: countries) if countries.present?
      query.autocomplete(term)
    end
  end
end
