# frozen_string_literal: true

module Locations
  class NameFinder
    MultipleResultsFound = Class.new(StandardError)

    def self.find_highest_admin_level(*terms)
      all_results = terms.map do |text|
        Locations::Name.autocomplete(text)
      end
      filtered_results = all_results.inject(:&)

      sorted_attributes = %w(
        country
        postal_code
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
        step_results = filtered_results.select { |result| terms.include? result[attr] }
        next if step_results.empty?
        if step_results.length == 1
          return step_results.first
        else
          raise Locations::NameFinder::MultipleResultsFound
        end
      end

      nil
    end
  end
end
