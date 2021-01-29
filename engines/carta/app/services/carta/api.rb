module Carta
  class Api
    LocationNotFound = Class.new(StandardError)

    def lookup(id:)
      uri = URI("#{base_url}/lookup?id=#{id}")
      response = request(uri: uri)
      result_from_carta(params: JSON.parse(response.body).dig("data"))
    end

    def suggest(query:)
      uri = URI("#{base_url}/suggest?query=#{query}&mode=internal")
      response = request(uri: uri)
      id = JSON.parse(response.body).dig("data", 0, "id")
      lookup(id: id)
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => "Token token=#{Settings.carta.token}"
      }
    end

    def request(uri:)
      http(uri: uri).request(Net::HTTP::Get.new(uri, headers))
    end

    def http(uri:)
      Net::HTTP.new(uri.host, uri.port).tap do |client|
        client.use_ssl = true
      end
    end

    def result_from_carta(params:)
      raise LocationNotFound if params.blank?

      Carta::Result.new(params.transform_keys(&:underscore))
    end

    def base_url
      Settings.carta.url
    end
  end
end
