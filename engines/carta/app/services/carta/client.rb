# frozen_string_literal: true

module Carta
  class Client
    LocationNotFound = Class.new(StandardError)

    class << self
      def lookup(id:)
        response = connection.get("lookup") do |req|
          req.params["id"] = id
        end
        raise LocationNotFound unless response.success?

        result_from_carta(params: JSON.parse(response.body)["data"])
      end

      def suggest(query:)
        response = connection.get("suggest") do |req|
          req.params["query"] = query
          req.params["mode"] = "internal"
        end

        raise LocationNotFound unless response.success?

        id = JSON.parse(response.body).dig("data", 0, "id")
        lookup(id: id)
      end

      private

      def result_from_carta(params:)
        raise LocationNotFound if params.blank?

        Carta::Result.new(params.transform_keys(&:underscore))
      end

      def connection
        Faraday.new(
          url: Settings.carta.url,
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Token token=#{Settings.carta.token}"
          }
        ) do |f|
          f.request :retry, retry_options
        end
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
