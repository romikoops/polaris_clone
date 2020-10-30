# frozen_string_literal: true

module Locations
  class LocationSearcher
    def self.get(identifier:)
      return Locations::Searchers::Default if identifier.blank?

      "Locations::Searchers::#{identifier.camelize}".safe_constantize || Locations::Searchers::Default
    end
  end
end
