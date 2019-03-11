# frozen_string_literal: true

class Admin::MapsController < Admin::AdminBaseController # rubocop:disable # Style/ClassAndModuleChildren
  def geojsons
    @hub = Hub.find(params[:id])
    @truckings = @hub.truckings
    response = Rails.cache.fetch("#{@truckings.cache_key}/geojson", expires_in: 12.hours) do
      @truckings.map{ |tl| response_hash(tl)}
    end
    response_handler(response.flatten)
  end
    
  def coverage
    coverage = Trucking::Coverage.find_by(hub_id: params[:id])&.geojson
    response_handler(coverage)
  end

  def country_overlay
    locations = Locations::Location.where(admin_level: params[:admin_level] || 6, country_code: params[:country_code].downcase)
    results = locations.map {|l| { geojson: l.geojson, name: l.name, id: l.id }}
    response_handler(results)
  end

  private

  def response_hash(result)
    { 
      name: result.location&.location&.name,
      geojson: result.location&.location&.geojson,
      trucking_rate_id: result.rate_id
    }
  end

end
