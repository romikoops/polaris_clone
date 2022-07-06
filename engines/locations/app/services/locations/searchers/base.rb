# frozen_string_literal: true

module Locations
  module Searchers
    class Base
      def self.id(data:)
        self.data(data: data)&.id
      end

      def self.data(data:)
        new(data: data).result
      end

      def initialize(data:)
        @data = data
      end

      def result
        @result ||= location.presence
      end

      private

      attr_reader :data

      def country_code
        @country_code ||= data[:country_code]
      end

      def geocoder_results
        @geocoder_results ||= Geocoder.search(
          data.values_at(:terms, :city, :province, :country_code).flatten.compact.join(" "),
          params: { region: country_code }
        )
      end

      def terms
        data[:terms]
      end

      def coordinates
        @coordinates ||= geometry["location"].symbolize_keys
      end

      def geometry
        @geometry ||= geocoder_results.map(&:geometry).first || {}
      end

      def lat
        @lat ||= data[:lat] || coordinates[:lat]
      end

      def lon
        @lon ||= data[:lng] || coordinates[:lng]
      end

      def point
        @point ||= RGeo::Cartesian.factory(srid: 4326).point(lon, lat)
      end

      def location
        raise NotImplementedError, "This method must be implemented in #{self.class.name}"
      end
    end
  end
end
