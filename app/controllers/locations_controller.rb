# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    input = params[:query]
    countries = params[:countries].split(',').map { |code| Country.find_by_code(code.upcase)&.name }.compact
    results =  Locations::Autocomplete.search(term: input, countries: countries) 

    response_handler(
      results: results.map do |result| 
        {
          geojson: result.geojson,
          description: result.description,
          postal_code: result.postal_code,
          city: result.city,
          country: result.country
        }
      end
    )
  end

  private
end
