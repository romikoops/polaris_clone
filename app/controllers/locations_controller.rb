# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    text = params[:query]
    filterific_params = {
      search_locations: params[:query]
    }
    
    (filterrific = initialize_filterrific(
      Location,
      filterific_params,
      available_filters: [
        :search_locations
      ],
      sanitize_params:   true
    )) || return
    # binding.pry
    locations = filterrific.find
    response_handler(
      results: locations.map(&:as_result_json)
    )

  end

  private

end
