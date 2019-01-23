# frozen_string_literal: true

module Locations
  class NameFinder
    MultipleResultsFound = Class.new(StandardError)

    def self.seeding(*terms)
      all_results = terms.map do |text|
        # search_match = Locations::Name.autocomplete(text)
        # direct_match =
        #   Locations::Name.where("name ILIKE ? OR alternative_names ILIKE ?", "%#{text}%", "%#{text}%")
        # search_match | direct_match
        Locations::Name.autocomplete(text)
      end
      filtered_results = all_results
        .reject(&:empty?)
        .inject(:&)
        .reject{|r| r.place_rank.nil?}
        .compact&.uniq
      # require 'pry';
      # binding.pry
      filtered_results.sort_by! {|r| r.place_rank }

      return filtered_results.first
      # # binding.pry
      # sorted_attributes = %w(
      #   country
      #   postal_code
      #   locality_2
      #   locality_3
      #   locality_4
      #   locality_5
      #   locality_6
      #   locality_7
      #   locality_8
      #   locality_9
      #   locality_10
      #   locality_11
      #   name
      # ).reverse

      #  terms_to_compare = terms.map(&:downcase)
      # sorted_attributes.each do |attr|

        
      #   step_results = filtered_results.select do |result|
      #     next if result[attr].nil?

      #     comparable_term = result[attr]&.downcase
      #       .sub('district', '')
      #       .sub('province', '')
      #       .sub('city', '')
      #       .sub('new', '')
      #       .strip

      #       terms_to_compare.include? comparable_term

      #   end

      #   next if step_results.empty?
      #   if step_results.length == 1 || step_results.map(&:location_id).uniq.length == 1
      #     return step_results.first.location
      #   else
      #     raise Locations::NameFinder::MultipleResultsFound
      #   end
      # end

    end
  end
end
