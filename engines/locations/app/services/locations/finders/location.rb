# frozen_string_literal: true

module Locations
  module Finders
    class Location < Locations::Finders::Base
      def perform
        results.find(&:location_id)
      end
    end
  end
end
