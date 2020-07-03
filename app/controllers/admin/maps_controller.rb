# frozen_string_literal: true

class Admin::MapsController < Admin::AdminBaseController # rubocop:disable Style/ClassAndModuleChildren
  def geojsons
    @hub = Hub.find_by(id: params[:id], sandbox: @sandbox)
    @truckings = @hub.truckings.where(sandbox: @sandbox)
    response = Rails.cache.fetch("#{@truckings.cache_key}/geojson", expires_in: 12.hours) do
      @truckings.first(20).map { |tl| response_hash(tl) }
    end
    response_handler(response.flatten)
  end

  def geojson
    trucking = Trucking::Trucking.find_by(id: params[:id], sandbox: @sandbox)
    response_handler(response_hash(trucking))
  end

  def editor_map_data
    trucking = Trucking::Trucking.find(params[:id])
    current_admin_level = trucking.location.location.admin_level
    effective_admin_level = params[:admin_level] || current_admin_level
    binds = {
      admin_level: effective_admin_level,
      west: params[:west],
      east: params[:east],
      south: params[:south],
      north: params[:north]
    }
    raw_query = 
    <<-SQL
    SELECT *
    FROM locations_locations
    WHERE locations_locations.admin_level = :admin_level
    AND ST_Contains(
            ST_MakeEnvelope(:west, :south, :east, :north, 4236)
    ,ST_SetSRID(locations_locations.bounds, 4236))
    SQL
    sanitized_query = ApplicationRecord.public_sanitize_sql([raw_query, binds])
    results = Locations::Location.find_by_sql(sanitized_query)
    center = trucking.location.location.bounds.centroid

    parsed_results = {
      data: results.map { |r| map_editor_hash(r) },
      center: { lat: center.y, lng: center.x },
      original_location: map_editor_hash(trucking.location&.location),
      current_admin_level: effective_admin_level
    }
    response_handler(parsed_results)
  end

  def coverage
    coverage = Trucking::Coverage.find_by(hub_id: params[:id], sandbox: @sandbox)&.geojson
    response_handler(coverage)
  end

  def country_overlay
    locations = Locations::Location.where(
      admin_level: params[:admin_level] || 6,
      country_code: params[:country_code].downcase
    )
    results = locations.map { |l| { geojson: l.geojson, name: l.name, id: l.id } }
    response_handler(results)
  end

  private

  def response_hash(result)
    if result.location&.zipcode
      {
        name: result.location&.zipcode,
        geojson: nil,
        trucking_id: result.id,
        cargo_class: result.cargo_class
      }
    elsif result.location&.distance
      {
        name: result.location&.distance,
        distance: result.location&.distance,
        geojson: nil,
        trucking_id: result.id,
        cargo_class: result.cargo_class
      }
    else
      {
        name: result.location&.location&.name,
        geojson: result.location&.location&.geojson,
        trucking_id: result.id,
        cargo_class: result.cargo_class
      }
    end
  end

  def map_editor_hash(result)
    return nil unless result

    {
      name: result&.name,
      geojson: result&.geojson,
      id: result.id,
      admin_level: result&.admin_level,
      country_code: result.country_code
    }
  end
end
