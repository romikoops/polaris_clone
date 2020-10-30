# frozen_string_literal: true

module Locations
  module Finders
    class PostalCode < Locations::Finders::Base
      def perform
        return nil unless postal_bounds

        result_with_location = results.find(&:location_id)
        return result_with_location if result_with_location

        results.first
      end

      def postal_bounds
        @postal_bounds ||= data[:postal_bounds]
      end

      def results
        @results ||= Locations::Name.where("ST_Contains(?, point)", postal_bounds)
          .search(
            data[:terms],
            fields: %i[name display_name alternative_names city postal_code],
            match: :word_middle,
            operator: "or",
            limit: 1
          ).results
      end
    end
  end
end
