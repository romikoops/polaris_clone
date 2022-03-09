# frozen_string_literal: true

class BackfillGeoIdsOnQueryWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    total_queries = queries.count
    total total_queries
    queries.find_each.with_index do |query, index|
      at (index + 1), "Backfilling query - #{index + 1}/#{total_queries}"

      origin_geo_id, destination_geo_id = get_origin_destination_geo_ids(query)

      query.origin_geo_id = origin_geo_id
      query.destination_geo_id = destination_geo_id

      # we need to do skip model validation as an exception case here since we will
      # not allow updating queries with origin or destination geo id from controllers.
      query.save!(validate: false)
    end
  end

  private

  def get_origin_destination_geo_ids(query)
    origin_geo_id = query.origin_geo_id
    destination_geo_id = query.destination_geo_id
    route_sections = Journey::RouteSection.where(result: query.results).order(order: :asc)

    if route_sections.present?
      origin_geo_id = route_sections.first.from.geo_id if origin_geo_id.blank?
      destination_geo_id = route_sections.last.to.geo_id if destination_geo_id.blank?
    end

    origin_geo_id = geo_id(string: query.origin, point: query.origin_coordinates) if origin_geo_id.blank?
    destination_geo_id = geo_id(string: query.destination, point: query.destination_coordinates) if destination_geo_id.blank?

    [origin_geo_id, destination_geo_id]
  end

  def geo_id(string:, point:)
    sleep(0.25) # Dont want to overload Carta with backfill
    begin
      Carta::Client.suggest(query: string).id
    rescue Carta::Client::LocationNotFound
      return if point.x.to_d == BigDecimal("0.0") || point.y.to_d == BigDecimal("0.0") # There are certain records with invalid origin/destination ex: destination: "deleted" what does it even mean? so in this case we cannot update the query

      Carta::Client.reverse_geocode(latitude: point.y, longitude: point.x).id
    end
  end

  def queries
    @queries ||= Journey::Query.where(origin_geo_id: nil).or(Journey::Query.where(destination_geo_id: nil))
  end
end
