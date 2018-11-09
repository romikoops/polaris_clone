# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    query = params[:query]
    raw_results = Location.autocomplete(query)
    # binding.pry
    response_handler(
      results: raw_results.map(&:as_result_json)
    )
  end

  private

end
