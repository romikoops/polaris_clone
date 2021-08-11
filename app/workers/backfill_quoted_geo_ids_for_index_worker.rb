# frozen_string_literal: true

class BackfillQuotedGeoIdsForIndexWorker
  include Sidekiq::Worker

  CartaBackfillFailed = Class.new(StandardError)

  def perform
    Journey::RoutePoint.where.not(locode: nil).find_in_batches(batch_size: 4000) do |route_points|
      response = Carta::Connection.connection.post("locations/counters/increment") do |request|
        request.body = JSON.generate({ doc_ids: route_points.pluck(:geo_id) })
      end

      raise CartaBackfillFailed unless response.success?
    end
  end
end
