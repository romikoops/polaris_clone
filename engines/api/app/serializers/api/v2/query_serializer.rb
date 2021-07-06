# frozen_string_literal: true

module Api
  module V2
    class QuerySerializer < Api::ApplicationSerializer
      attributes %i[id aggregated load_type origin_name destination_name reference modes_of_transport client load_type offer_id issue_date]

      attribute :origin_name, &:origin

      attribute :destination_name, &:destination

      attribute :issue_date, &:created_at

      attribute :client do |query|
        query.client && ClientSerializer.new(ClientDecorator.new(query.client))
      end
    end
  end
end
