# frozen_string_literal: true

module Carta
  class Client < Carta::Connection
    LocationNotFound = Class.new(StandardError)
    ServiceUnavailable = Class.new(StandardError)

    class << self
      def lookup(id:)
        response = connection.get("lookup") do |req|
          req.params["id"] = id
        end
        raise ServiceUnavailable unless response.success?

        result_from_carta(params: JSON.parse(response.body)["data"])
      end

      def suggest(query:)
        response = connection.get("suggest") do |req|
          req.params["query"] = query
          req.params["mode"] = "internal"
        end

        raise ServiceUnavailable unless response.success?

        suggestion_to_result(response: response)
      end

      def reverse_geocode(latitude:, longitude:)
        response = connection.get("reverse_geocode") do |req|
          req.params["latitude"] = latitude
          req.params["longitude"] = longitude
        end

        raise ServiceUnavailable unless response.success?

        suggestion_to_result(response: response)
      end

      private

      def result_from_carta(params:)
        raise LocationNotFound if params.blank?

        Carta::Result.new(params.transform_keys(&:underscore))
      end

      def suggestion_to_result(response:)
        id = JSON.parse(response.body).dig("data", 0, "id")
        raise LocationNotFound if id.blank?

        lookup(id: id)
      end

      def retry_options
        {
          max: 2,
          interval: 1,
          retry_statuses: [503]
        }
      end
    end
  end
end
