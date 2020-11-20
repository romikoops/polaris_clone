# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def index
    input = params[:query]

    country_codes = params[:countries].split(",").map(&:downcase).compact
    raw_results = Locations::Autocomplete.search(term: input, country_codes: country_codes)
    results = raw_results.slice(0, 5).map { |result|
      {
        geojson: result.geojson,
        description: result.display_name || result.name || result.combined_names,
        postal_code: result.postal_code,
        city: result.city || result.state,
        country: result.country,
        center: result.lat_lng
      }
    }

    response_handler(
      results: results
    )
  end
end
