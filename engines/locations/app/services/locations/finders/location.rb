# frozen_string_literal: true

module Locations
  module Finders
    class Location < Locations::Finders::Base
      def perform
        results.find(&:location_id) || location_fallback
      end

      def location_fallback
        @location_fallback ||= Locations::Location.where(country_code: country_code).find_by("name ILIKE ?", "%#{terms.first}%")
      end
    end
  end
end
