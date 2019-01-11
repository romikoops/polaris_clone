# frozen_string_literal: true

module Locations
  class Autocomplete
    def self.search(term:, countries:, lang: 'en')
      query = Locations::Name

      query = query.where(country: countries) if countries.present?
      
      query.autocomplete(term).map{|result|
        require 'pry';
        binding.pry
         LocationDecorator.new(result.location)}
    end
  end
end
