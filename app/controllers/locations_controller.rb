# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    query = params[:query]
    countries = [params[:countries]].map { |code| Country.find_by_code(code.upcase)&.name }.compact
    country_query = if countries.empty?
      Location.all
    else
      Location.where(country: countries)
    end
    valid_query = country_query.where.not(city: nil, country: nil, postal_code: nil)
    results = valid_query.autocomplete(query)
    
    response_handler(
      results: results.map(&:as_result_json)
    )
  end

  private
end
