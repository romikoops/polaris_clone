# frozen_string_literal: true

module Locations
  class Autocomplete


    def self.find_locations(input, country_params)
      query = Locations::Name.all
      countries = country_params.split(',').map { |code| Country.find_by_code(code.upcase)&.name }.compact
      query = query.where(country: countries) if countries.present?
      results = query.autocomplete(input)

      filtered_results = all_results.inject(:&)

      sorted_attributes = %w(
        country
        locality_2
        locality_3
        locality_4
        locality_5
        locality_6
        locality_7
        locality_8
        locality_9
        locality_10
        locality_11
        name
      ).reverse

      sorted_attributes.each do |attr|
        step_results = filtered_results.select { |result| terms.include?result[attr] }
        next if step_results.empty?
        if step_results.length == 1
          return step_results.first
        else
          raise Locations::Autocomplete::MultipleResultsFound
        end
      end

      nil
    end
  end
end
