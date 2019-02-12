# frozen_string_literal: true

module Locations
  class NameFinder
    MultipleResultsFound = Class.new(StandardError)

    def self.seeding(*terms)
      Locations::Name
        .search(terms, fields: [:name, :display_name, :postal_code], limit: 1, match: :word_middle, operator: 'or')
        .results
        .first
    end
  end
end
