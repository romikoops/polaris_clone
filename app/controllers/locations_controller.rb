# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    input = params[:query]
    country_codes = params[:countries].split(',').map(&:downcase).compact
    results = Locations::Autocomplete.search(term: input, country_codes: country_codes) 

    response_handler(
      results: results.map do |result| 
        {
          geojson: result.geojson,
          description: result.display_name,
          postal_code: result.postal_code,
          city: result.city || result.state,
          country: result.country,
          location: result.lat_lng
        }
      end
    )
  end

end
