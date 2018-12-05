# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    input = params[:query]
    countries = [params[:countries]].map { |code| Country.find_by_code(code.upcase)&.name }.compact
    query =  Location.all 
    query = query.where(country: countries) if countries.present?
    query = query.where.not(city: nil, country: nil, postal_code: nil)
    results = query.autocomplete(input)
    
    response_handler(
      results: results.map(&:as_result_json)
    )
  end

  private
end
