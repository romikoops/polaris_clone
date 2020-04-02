# frozen_string_literal: true

module Trucking
  module Queries
    class Availability < ::Trucking::Queries::Base
      def perform
        truckings_for_query.order("#{@order_by} DESC NULLS LAST")
      end
    end
  end
end
