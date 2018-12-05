# frozen_string_literal: true

class LocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    query = params[:query]
    countries = [params[:countries]].map { |code| Country.find_by_code(code.upcase)&.name }.compact
    raw_results = Location.autocomplete(query)
    results = if countries.empty?
                raw_results
              else
                raw_results.where(country: countries)
                # raw_results.select { |result| countries.include?(result.country) }
              end
    response_handler(
      results: results.map(&:as_result_json)
    )
  end

  private
end
