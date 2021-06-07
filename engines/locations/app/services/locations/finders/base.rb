# frozen_string_literal: true

module Locations
  module Finders
    class Base
      def self.data(data:)
        new(data: data).perform
      end

      def initialize(data:)
        @data = data
      end

      def perform
        results.first
      end

      private

      attr_reader :data

      def terms
        @terms ||= data[:terms]
      end

      def country_code
        @country_code ||= data[:country_code]
      end

      def results
        @results ||= Locations::Name
          .search(
            data[:terms],
            fields: %i[name display_name alternative_names city postal_code],
            match: :word_middle,
            limit: 30,
            operator: "or",
            where: { country_code: country_code }
          )
          .results
      end
    end
  end
end
