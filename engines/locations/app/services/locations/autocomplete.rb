# frozen_string_literal: true

module Locations
  class Autocomplete
    def self.search(term:, country_codes: [], lang: 'en')
      query = Locations::Name

      query = query.where(country_code: country_codes.map(&:downcase)) unless country_codes.empty?
      query.autocomplete(term).order(place_rank: :asc)
    end
  end
end
