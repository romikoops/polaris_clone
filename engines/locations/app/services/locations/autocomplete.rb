# frozen_string_literal: true

module Locations
  class Autocomplete
    def self.search(term:, country_codes: [], lang: 'en')
      query = Locations::Name
      query = query.where(country_code: country_codes.map(&:downcase)) unless country_codes.empty?
      query = query.search(term, fields: [:name, :display_name, :postal_code], match: :word_middle, operator: 'or').results
      query.map{|result| Locations::NameDecorator.new(result)}
    end
  end
end
