# frozen_string_literal: true

module Carta
  class BulkIndexUpdater < Carta::Connection
    CartaBulkUpdateFailed = Class.new(StandardError)

    class << self
      def perform
        response = connection.post(
          "v1/locations/counters/increment",
          { doc_ids: geo_ids }
        )
        raise CartaBulkUpdateFailed unless response.success?
      end

      private

      def geo_ids
        yesterday = Time.zone.yesterday
        Journey::RoutePoint.where.not(locode: nil)
          .where("created_at > ? AND created_at < ?", yesterday.beginning_of_day, yesterday.end_of_day)
          .pluck(:geo_id)
      end
    end
  end
end
