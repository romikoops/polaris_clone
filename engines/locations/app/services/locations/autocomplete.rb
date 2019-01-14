# frozen_string_literal: true

module Locations
  class Autocomplete
    def self.search(term:, countries:, lang: 'en')
      query = Locations::Name

      query = query.where(country: countries) if countries.present?
      require 'pry';
      binding.pry
      location_ids = query
        .autocomplete(term)
        .pluck(:location_id)
        .uniq
      Locations::Location.where(id: location_ids)
        .map{ |location| LocationDecorator.new(location) }
    end
  end
end
