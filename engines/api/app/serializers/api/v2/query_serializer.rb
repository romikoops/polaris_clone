# frozen_string_literal: true

module Api
  module V2
    class QuerySerializer < Api::ApplicationSerializer
      attributes [:id, :aggregated, :load_type, :origin_name, :destination_name]

      attribute :origin_name do |query|
        query.origin
      end

      attribute :destination_name do |query|
        query.destination
      end
    end
  end
end
