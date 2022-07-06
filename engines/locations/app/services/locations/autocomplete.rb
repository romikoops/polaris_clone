# frozen_string_literal: true

module Locations
  class Autocomplete
    def self.search(term:, country_codes: [], lang: "en")
      query = if country_codes.empty?
        Locations::Name.search(
          term,
          fields: %i[name display_name postal_code],
          match: :word_middle,
          operator: "or"
        ).results
      else
        Locations::Name.search(
          term,
          where: {country_code: country_codes},
          fields: %i[name display_name postal_code],
          match: :word_middle,
          operator: "or"
        ).results
      end
      query.select(&:point).map { |result| Locations::NameDecorator.new(result) }
    end
  end
end
