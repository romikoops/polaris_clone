# frozen_string_literal: true

module Api
  module V2
    class QuerySerializer < Api::ApplicationSerializer
      attributes %i[id aggregated billable load_type origin_name destination_name reference modes_of_transport client load_type offer_id issue_date origin_id destination_id parent_id company_id cargo_ready_date]

      attribute :origin_name, &:origin

      attribute :destination_name, &:destination

      attribute :origin_id, &:origin_geo_id

      attribute :destination_id, &:destination_geo_id

      attribute :issue_date, &:created_at

      attribute :client do |query|
        query.client && ClientSerializer.new(ClientDecorator.new(query.client))
      end
    end
  end
end
