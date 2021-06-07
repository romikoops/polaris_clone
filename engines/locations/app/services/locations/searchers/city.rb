# frozen_string_literal: true

module Locations
  module Searchers
    class City < Locations::Searchers::Base
      def location
        locations_name&.location || fallback_location
      end

      private

      def locations_name
        @locations_name ||= [
          primary_name,
          secondary_name,
          fallback_name
        ].find(&:present?)
      end

      def primary_name
        @primary_name ||= Locations::Finders::Location.data(
          data: { country_code: country_code, terms: terms }
        )
      end

      def secondary_name
        @secondary_name ||= Locations::Finders::Location.data(
          data: { country_code: country_code, terms: [upper_term] }
        )
      end

      def fallback_name
        @fallback_name ||= Locations::Finders::Default.data(
          data: data
        )
      end

      def fallback_location
        @fallback_location ||= Locations::Searchers::Point.data(
          data: data
        )
      end

      def upper_term
        @upper_term ||= terms.is_a?(Array) ? terms.last : terms.split.last
      end
    end
  end
end
