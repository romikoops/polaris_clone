# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    input = params[:query]

    experiment = Experiments::Trucking::Autocomplete.new(name: 'locations_search')
    experiment.use do
      countries = params[:countries].split(',').map { |code| Country.find_by_code(code.upcase)&.name }.compact
      query = Location.all
      query = query.where(country: countries) if countries.present?
      query = query.where.not(city: nil, country: nil, postal_code: nil)
      results = query.autocomplete(input)
      results.map(&:as_result_json)
    end
    experiment.try do
      country_codes = params[:countries].split(',').map(&:downcase).compact
      raw_results = Locations::Autocomplete.search(term: input, country_codes: country_codes)
      raw_results.map do |result|
        {
          geojson: result.geojson,
          description: result.display_name,
          postal_code: result.postal_code,
          city: result.city || result.state,
          country: result.country,
          location: result.lat_lng
        }
      end
    end
    results = experiment.run
    response_handler(
      results: results
    )
  end
end
