# frozen_string_literal: true

class DedupeRoutePointsWorker
  include Sidekiq::Worker

  def perform(*args)
    Journey::RoutePoint.select(:geo_id).distinct.each do |record|
      route_points = Journey::RoutePoint.where(geo_id: record.geo_id)
      next if route_points.count == 1

      ActiveRecord::Base.transaction do
        route_point = route_points.first
        other_route_points = Journey::RoutePoint.where(geo_id: record.geo_id).where.not(id: route_point.id)
        Journey::RouteSection.where(from_id: other_route_points.ids).find_each do |route_section|
          route_section.update!(from_id: route_point.id)
        end
        Journey::RouteSection.where(to_id: other_route_points.ids).find_each do |route_section|
          route_section.update!(to_id: route_point.id)
        end
        Journey::LineItem.where(route_point_id: other_route_points.ids).find_each do |line_item|
          line_item.update!(route_point_id: route_point.id)
        end
        other_route_points.destroy_all
      end
    end
  end
end
