# frozen_string_literal: true

class RedupeRoutePointsWorker
  include Sidekiq::Worker

  def perform(*args)
    Journey::RoutePoint.where(geo_id: nil).find_each do |route_point|
      handle_postal_code_update(route_point: route_point)
      update_references(route_point: route_point)
    end
    geo_ids_for_updating.each do |geo_id|
      route_point = Journey::RoutePoint.find_by(geo_id: geo_id)
      handle_carta_update(route_point: route_point)
      update_references(route_point: route_point)
    end
  end

  def geo_ids_for_updating
    ActiveRecord::Base.connection.execute("
      SELECT DISTINCT geo_id FROM journey_route_points
      WHERE geo_id IS NOT NULL
      GROUP BY geo_id HAVING COUNT(*) = 1
    ").field_values("geo_id")
  end

  def handle_carta_update(route_point:)
    carta_result = Carta::Client.lookup(id: route_point.geo_id)
    route_point.update!(
      postal_code: carta_result.postal_code || "",
      city: carta_result.locality || "",
      street: carta_result.street || "",
      street_number: carta_result.street_number || "",
      administrative_area: carta_result.administrative_area || "",
      country: carta_result.country
    )
  end

  def handle_postal_code_update(route_point:)
    postal_location = Locations::Name.where(
      "ST_DWithin(point::geography, ?, 50000)", route_point.coordinates
    ).find_by(postal_code: route_point.name[/[0-9]{5}/])
    route_point.update!(
      postal_code: postal_location.postal_code || "",
      city: postal_location.city || "",
      street: postal_location.street || "",
      street_number: "",
      administrative_area: postal_location.state || "",
      country: postal_location.country_code,
      geo_id: "itsmycargo::BACKFILL-#{postal_location.id}"
    )
  end

  def update_references(route_point:)
    Journey::RouteSection.where(from: route_point).each do |from_route_section|
      from_route_section.update(from: route_point.dup)
    end
    Journey::RouteSection.where(to: route_point).each do |to_route_section|
      to_route_section.update(to: route_point.dup)
    end
  end
end
