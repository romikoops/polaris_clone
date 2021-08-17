# frozen_string_literal: true

module Carta
  class Connection
    class << self
      def connection
        Faraday.new(
          url: Settings.carta.url,
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Token token=#{Settings.carta.token}"
          }
        ) do |conn|
          conn.request :retry, retry_options
        end
      end

      private

      def retry_options
        {
          max: 2,
          interval: 1
        }
      end
    end
  end
end
