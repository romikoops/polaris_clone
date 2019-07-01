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
    else
      {
        name: result.location&.location&.name,
        geojson: result.location&.location&.geojson,
        trucking_id: result.id,
        cargo_class: result.cargo_class
      }
    end
  end
end
