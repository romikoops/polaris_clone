# frozen_string_literal: true

module Integrations
  module ChainIo
    class Sender
      BASE_URL = 'https://webhooks.chain.io'

      def initialize(data:, organization_id:)
        @body = data
        @chainio_configs = OrganizationManager::ScopeService.new(
          target: ::Organizations::Organization.find(organization_id)
        ).fetch(:integrations).dig(:chainio)
      end

      def send_shipment
        uri = URI(tenant_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        header = { 'Content-Type' => 'application/json', 'x-api-key' => organization_api_key }
        request = Net::HTTP::Post.new(uri, header)

        request.body = @body.to_json

        response = http.request(request)

        Rails.logger.info "Chain.io response: #{response.body}"
      end

      private

      def organization_flow_id
        @chainio_configs[:flow_id]
      end

      def organization_api_key
        @chainio_configs[:api_key]
      end

      def tenant_url
        "#{BASE_URL}/flow/#{organization_flow_id}/booking"
      end
    end
  end
end
