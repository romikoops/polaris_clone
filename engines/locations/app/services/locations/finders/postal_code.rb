# frozen_string_literal: true

module Locations
  module Finders
    class PostalCode < Locations::Finders::Base
      def perform
        return nil unless postal_bounds

        result_with_location = results_limited_by_postal_bounds.find(&:location_id)
        return result_with_location if result_with_location

        results_limited_by_postal_bounds.first
      end

      def postal_bounds
        @postal_bounds ||= data[:postal_bounds]
      end

      def results
        @results ||= Locations::Name.search(
          data[:terms],
          fields: %i[name display_name alternative_names city postal_code],
          match: :word_middle,
          operator: "or",
          limit: 1
        ).results
      end

      def results_limited_by_postal_bounds
        @results_limited_by_postal_bounds ||= Locations::Name.where("ST_Contains(?, ST_SetSRID(point, 4326))", postal_bounds).where(id: results.pluck(:id))
      end
    end
  end
end
