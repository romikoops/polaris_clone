# frozen_string_literal: true

module Locations
  class Autocomplete
    def self.search(term:, country_codes: [], lang: 'en')
      query = Locations::Name
      query = if country_codes.empty?
                query.search(
                  term,
                  fields: %i(name display_name postal_code),
                  match: :word_middle,
                  operator: 'or'
                ).results
              else
                query.search(
                  term,
                  where: { country_code: 'de' },
                  fields: %i(name display_name postal_code),
                  match: :word_middle,
                  operator: 'or'
                ).results
              end
      query.map { |result| Locations::NameDecorator.new(result) }
    end
  end
end
