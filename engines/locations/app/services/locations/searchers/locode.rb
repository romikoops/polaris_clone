# frozen_string_literal: true

module Locations
  module Searchers
    class Locode < Locations::Searchers::Base
      def location
        locations_name&.location || Locations::Location.find_by(name: locode)
      end

      private

      def locations_name
        @locations_name ||= Locations::Name.find_by(locode: locode)
      end

      def locode
        @locode ||= data[:locode]
      end
    end
  end
end
