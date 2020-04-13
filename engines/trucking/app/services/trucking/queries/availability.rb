# frozen_string_literal: true

module Trucking
  module Queries
    class Availability < ::Trucking::Queries::Base
      def perform
        truckings_for_query.order('group_id DESC NULLS LAST')
      end
    end
  end
end
