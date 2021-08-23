# frozen_string_literal: true

module Carta
  class BulkIndexUpdater < Carta::Connection
    CartaBulkUpdateFailed = Class.new(StandardError)

    class << self
      def perform
        return if geo_ids.empty?

        response = connection.post("locations/counters/increment") do |request|
          request.body = JSON.generate({ doc_ids: geo_ids })
        end

        raise CartaBulkUpdateFailed unless response.success?
      end

      private

      def geo_ids
        @geo_ids ||= Journey::RoutePoint.where.not(locode: nil)
          .where(
            "created_at > ? AND created_at < ?",
            Time.zone.yesterday.beginning_of_day,
            Time.zone.yesterday.end_of_day
          )
          .pluck(:geo_id)
      end
    end
  end
end
