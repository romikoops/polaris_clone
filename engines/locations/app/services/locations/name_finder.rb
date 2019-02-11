# frozen_string_literal: true

module Locations
  class NameFinder
    MultipleResultsFound = Class.new(StandardError)

    def self.seeding(*terms)
      all_results = terms.map do |text|
        ## Checking for non latin characters characters is too slow for the moment
        # search_match = Locations::Name.autocomplete(text)
        # direct_match =
        #   Locations::Name.where("name ILIKE ? OR alternative_names ILIKE ?", "%#{text}%", "%#{text}%")
        # search_match | direct_match
        require 'pry'; binding.pry
        Locations::Name.search text, fields: [:name, :display_name, :postal_code], match: :text_middle
      end
      filtered_results = all_results
                          .reject(&:empty?)
                          .inject(:&)
                          .reject{|r| r.place_rank.nil?}
                          .compact&.uniq

      filtered_results.sort_by!(&:place_rank)

      filtered_results.first


    end
  end
end
