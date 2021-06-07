# frozen_string_literal: true

module ExcelDataServices
  module Extractors
    class GeoDataPreparer
      def self.data(identifier:, raw_data:)
        new(identifier: identifier, raw_data: raw_data).data
      end

      def initialize(identifier:, raw_data:)
        @identifier = identifier
        @raw_data = raw_data
      end

      def data
        send(identifier.to_sym)
      end

      private

      attr_reader :identifier, :raw_data

      def nested_city
        {
          city: raw_data["primary"],
          province: raw_data["secondary"],
          country_code: raw_data["country_code"]
        }
      end

      def city
        {
          terms: raw_data.values_at("primary", "secondary"),
          country_code: raw_data["country_code"]
        }
      end

      def locode
        {
          locode: raw_data["primary"].upcase
        }
      end

      def postal_city
        postal_code, name = raw_data["primary"].split("-").map { |string| string.strip.upcase }

        {
          postal_code: postal_code,
          country_code: raw_data["country_code"],
          terms: [name]
        }
      end
    end
  end
end
